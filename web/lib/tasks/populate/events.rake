require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'

require_relative '../../geographic.rb'
require_relative '../../../config/initializers/shrine.rb'
require_relative '../../../app/uploaders/event_image_uploader'

module PopulateEventsRake

	def create_place(item)
		return if item['deleted'] == 'true'

		place = Place.find_by("lower(details ->> 'name') = ?", item['place_name'].downcase)

		if place
			puts "Local: #{place.id} #{place.details['name']} - Lugar já existe".yellow
			set_place_image(place, item) unless place.image_data?
		else
			@geocode = Geocoder.search(item['address']).first if item['address']

			place = Place.create!({
															details:    {
																name: item['place_name']
															},
															geographic: {
																address: item['address']
															}
														})

			SetGeolocationJob.perform_later(place.id)
			set_place_image(place, item)
			puts "Local: #{place.id} #{place.details_name} - Lugar criado".white
		end

		place
	end

	def set_place_image(place, item)
		return if item['place_cover_url'].blank?
		return if place.image_data?

		begin
			place_cover_file = Down.download(item['place_cover_url'])
		rescue Down::Error => e
			puts "Local: #{item['place_name']} - Erro no download da imagem (#{item['place_cover_url']}) - #{e}".red
		else
			puts "Local: #{item['place_name']} - Download da imagem (#{item['place_cover_url']}) - Sucesso".white
			begin
				place.image = place_cover_file
				puts "Local: #{item['place_name']} - Upload de imagem".white
				place.save!
			rescue
				puts "Local: #{item['place_name']} - Erro no upload da image #{e}".red
			end
		end
	end

	def create_organizers(item)
		return if item['deleted'] == 'true'
		return if item['organizers'].blank?

		item['organizers'].map do |organizer_data|
			organizer = Organizer.find_by("lower(details ->> 'name') = ?", organizer_data['name'].downcase)

			if organizer.present?
				puts "Organizador: #{organizer.details['name']} - já existe".yellow
			else
				organizer = Organizer.create!({
																				details: {
																					name:       organizer_data['name'],
																					source_url: organizer_data['source_url']
																				}
																			})

				puts "Organizador: #{organizer_data['name']} - criado".white
			end

			set_organizer_image(organizer, organizer_data) unless organizer.image_data?
			organizer
		end
	end

	def associate_event_organizers(event, organizers)
		organizers.each do |organizer|
			unless event.organizers.include?(organizer)
				event.organizers << organizer
				puts "Organizador: #{organizer.details_name} - associado".white
			end
		end
	end

	def set_organizer_image(organizer, organizer_data)
		return if organizer_data['cover_url'].blank?
		return if organizer.image_data?

		begin
			organizer_cover_file = Down.download(organizer_data['cover_url'])
		rescue Down::Error => e
			puts "Organizador: #{organizer_data['name']} - Erro no download da imagem (#{organizer_data['cover_url']}) - #{e}".red
		else
			puts "Organizador: #{organizer_data['name']} - Download da imagem (#{organizer_data['cover_url']}) - Sucesso".white
			begin
				organizer.image = organizer_cover_file
				puts "Organizador: #{organizer_data['name']} - Upload de imagem".white
				organizer.save!
			rescue
				puts "Organizador: #{organizer_data['name']} - Erro no upload da image #{e}".red
			end
		end
	end

	def save_event(event)
		event.slug = nil

		if event.save!
			@events_create_counter += 1
			puts "Evento: #{event.id}, #{event.details['name'][0..60]} - Salvo!".green
			true
		end
	end

	def get_features_of_event(event)
		puts "Evento: #{event.details_name} - Adicionando features".white
		features_query  = event.text_to_ml
		features_params = { 'query' => features_query }

		features_uri = URI("#{ENV['API_URL']}:5000/event/features")

		features_response = Net::HTTP.post_form(features_uri, features_params)
		features_data     = JSON.parse(features_response.try(:body))

		features_response_is_success = features_response.is_a?(Net::HTTPSuccess)

		if features_response_is_success
			event.ml_data.deep_merge!(
				'stemmed' => features_data['stemmed']
			)
		else
			puts "Evento: #{event.details_name} - Erro durante a extração de features".red
		end
	end

	def classify_event(event)
		puts "Evento: #{event.details_name} - Adicionando classificação".white
		label_query  = event.text_to_ml
		label_params = { 'query' => label_query }

		label_uri = URI("#{ENV['API_URL']}:5000/event/label")

		label_response = Net::HTTP.post_form(label_uri, label_params)
		label_data     = JSON.parse(label_response.try(:body))

		label_response_is_success = label_response.is_a?(Net::HTTPSuccess)

		if label_response_is_success
			event.ml_data.deep_merge!(
				personas:   {
					primary:   {
						name:  label_data['classification']['personas']['primary']['name'],
						score: label_data['classification']['personas']['primary']['score']
					},
					secondary: {
						name:  label_data['classification']['personas']['secondary']['name'],
						score: label_data['classification']['personas']['secondary']['score']
					},
					outlier:   false
				},
				categories: {
					primary:   {
						name:  label_data['classification']['categories']['primary']['name'],
						score: label_data['classification']['categories']['primary']['score']
					},
					secondary: {
						name:  label_data['classification']['categories']['secondary']['name'],
						score: label_data['classification']['categories']['secondary']['score']
					},
					outlier:   false
				},
				price: {
					name:  label_data['classification']['price']['name'],
					score: label_data['classification']['price']['score']
				}
			)

			if label_data['classification']['categories']
				labels     = label_data['classification']['categories']
				categories = Category.where("(details ->> 'name') IN (:categories)", categories: [labels['primary']['name']])
				event.categories = [] if event.categories.present?
				event.categories << categories
				puts "Evento: #{event.details_name} - #{labels['primary']['name']} - Eventos classificado".white
			end

		else
			puts "Evento: #{event.details_name} - Erro durante a classificação".red
		end
	end

	def set_cover(item, event)
		return if item['cover_url'].blank?

		begin
			event_cover_file = Down.download(item['cover_url'])
		rescue Down::Error => e
			puts "Evento: #{item['name']} - Erro no download da imagem (#{item['cover_url']}) - #{e}".red
			return false
		else
			puts "Evento: #{item['name']} - Download da imagem (#{item['cover_url']}) - Sucesso".white
		end

		return unless event_cover_file

		begin
			event.image = event_cover_file
			puts "Evento: #{item['name']} - Upload de imagem".white
		rescue
			puts "Evento: #{item['name']} - Erro no upload da image #{e}".red
			return false
		end

		true
	end

	def associate_event_place(event, place)
		unless place.events.include?(event)
			place.events << event
			puts "Local: #{place.details_name} - Local associado".white
		end
	end

	def read_file
		files              = Dir['/var/www/scrapy/data/scraped/*']
		@current_file_name = (files.select { |file| file[/events-\d{8}-\d{6}\.jsonl$/] }).max

		if @current_file_name.nil?
			puts "Não foi encontrado nenhum arquivo na pasta /scraped".white
			abort
		end

		puts "Lendo arquivo JSON #{@current_file_name} da pasta /scraped".white

		@current_file = File.read(@current_file_name)
	end

	def create_event(item)
		if item['deleted'] == 'true'
			Event.destroy_by("(details ->> 'source_url') LIKE ?", "%#{item['source_url']}%")
			puts "Evento: #{item['source_url']} - Evento deletado".yellow
			return :deleted
		end

		if item['datetimes'].blank?
			puts "Evento: #{item['name']} - Evento sem data raspada".red
			return false
		end

		if item['description'].blank?
			puts "Evento: #{item['name']} - Evento sem descrição raspada".red
			return false
		end

		event = Event.find_by("(details ->> 'source_url') LIKE ?", "%#{item['source_url']}%")

		if event
			puts "#{@events_create_counter}: #{item['name']} - Evento já existe".yellow

			event.details.deep_merge!(
				name:        item['name'],
				description: item['description'],
				ticket_url:  item['ticket_url'],
				prices:      item['prices'] || []
			)

			event.ocurrences.deep_merge!(
				dates: item['datetimes'].map { |datetime| datetime.to_datetime }
			)

			event.geographic.deep_merge!(
				address:      item['address'],
				latlon:       @geocode.try(:coordinates),
				neighborhood: @geocode.try { |geo| geo.address_components_of_type(:sublocality)[0]["long_name"] },
				city:         item['address'] ? item['address'][/Porto Alegre/] : nil,
				cep:          Geographic.get_cep_from_address(item['address'])
			)
			puts "#{item['name']} - atualizado".white

			event

		else
			event   = Event.new

			puts "#{@events_create_counter}: #{item['name']} - Evento criado".white

			event.details.deep_merge!(
				name:        item['name'],
				description: item['description'],
				source_url:  item['source_url'],
				ticket_url:  item['ticket_url'],
				prices:      item['prices'] || []
			)

			event.ocurrences.deep_merge!(
				dates: item['datetimes']
			)

			event.geographic.deep_merge!(
				address:      item['address'],
				latlon:       @geocode.try(:coordinates),
				neighborhood: @geocode.try { |geo| geo.address_components_of_type(:sublocality)[0]["long_name"] },
				city:         item['address'] ? item['address'][/Porto Alegre/] : nil,
				cep:          Geographic.get_cep_from_address(item['address'])
			)

			event
		end
	end

	def create_artifact
		timestr  = DateTime.now.strftime("%Y%m%d-%H%M%S")
		artifact = Artifact.create(
			details: {
				name: @current_file_name,
				type: 'scraped'
			}
		)

		artifact.file.attach(io: File.open("#{@current_file_name}"), filename: "events-#{timestr}.jsonl", content_type: "application/json")
	end
end

namespace :populate do
	desc 'Populate events scraped from facebook'
	task events: :environment do

		include PopulateEventsRake

		puts "Task populate:events iniciada em #{DateTime.now}".white

		last_task_performed = Artifact.where(details: {
			name: "populate:events",
			type: "task"
		}).first

		# noinspection RubyArgCount
		@uploader               = EventImageUploader.new(:store)
		@events_create_counter  = 0
		@events_similar_counter = 0

		read_file

		if last_task_performed.try { |ltp| ltp.data['last_file_used'] == @current_file_name }
			puts "Task já realizada para o arquivo #{@current_file_name}".white
			abort
		end

		create_artifact

		begin
			data = JSONL.parse(@current_file)
		rescue JSON::ParserError => e
			puts "Erro ao ler arquivo JSON: #{e}".red
			return
		else
			puts "Arquivo JSON parseado".white
		end

		data.each do |item|
			event      = create_event(item)
			place      = create_place(item)
			organizers = create_organizers(item)

			if event == :deleted
				puts "#{item['name']} - Próximo (evento deletado)".yellow
				next
			end

			unless event
				puts "#{item['name']} - Próximo (evento não criado)".yellow
				next
			end

			associate_event_organizers(event, organizers)
			associate_event_place(event, place)
			next unless set_cover(item, event)
			get_features_of_event(event)
			classify_event(event)
			save_event(event)
		end

		if last_task_performed
			last_task_performed.touch
		else
			Artifact.create(
				details: {
					name: "populate:events",
					type: "task"
				},
				data:    {
					last_file_used: @current_file_name
				})
		end

		puts "Task populate:events finalizada em #{DateTime.now}}".white

		if @events_create_counter == 0
			puts "Nenhum evento criado para o arquivo #{@current_file_name}, abortando próximas tasks...".yellow
			abort
		end
	end
end
