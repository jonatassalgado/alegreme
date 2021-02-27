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
		return if item['deleted']

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
		return unless item['place_cover_url']
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
		return if item['deleted']
		return unless item['organizers']

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
		return unless organizer_data['cover_url']
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

	def classify_event(event, ml_data)
		@label_query  = Base64.encode64(ml_data['stemmed'])
		@label_params = { query: @label_query }

		@label_uri       = URI("#{ENV['API_URL']}:5000/event/label")
		@label_uri.query = URI.encode_www_form(@label_params)

		@label_response = Net::HTTP.get_response(@label_uri)
		@label_data     = JSON.parse(@label_response.try(:body))

		@label_response_is_success = @label_response.is_a?(Net::HTTPSuccess)

		if @label_response_is_success
			puts "Evento: #{event.details_name} - Adicionando classificação".white
			event.ml_data.deep_merge!(
				personas:   {
					primary:   {
						name:  @label_data['classification']['personas']['primary']['name'],
						score: @label_data['classification']['personas']['primary']['score']
					},
					secondary: {
						name:  @label_data['classification']['personas']['secondary']['name'],
						score: @label_data['classification']['personas']['secondary']['score']
					},
					outlier:   false
				},
				categories: {
					primary:   {
						name:  @label_data['classification']['categories']['primary']['name'],
						score: @label_data['classification']['categories']['primary']['score']
					},
					secondary: {
						name:  @label_data['classification']['categories']['secondary']['name'],
						score: @label_data['classification']['categories']['secondary']['score']
					},
					outlier:   false
				}
			)

			if @label_data['classification']['categories']
				labels = @label_data['classification']['categories']

				categories = Category.where("(details ->> 'name') IN (:categories)", categories: [labels['primary']['name'], labels['secondary']['name']])
				event.categories << categories
			end

		else
			puts "Evento: #{event.details_name} - Erro durante a classificação".red
		end
	end

	def set_cover(item, event)
		return unless item['cover_url']

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
		if item['deleted']&.present?
			Event.destroy_by("(details ->> 'source_url') = ?", item['source_url'])
			puts "Evento: #{item['source_url']} - Evento deletado".yellow
			return [false, false]
		end

		if item['datetimes']&.empty?
			puts "Evento: #{item['name']} - Evento sem data raspada".red
			return [false, false]
		end

		if item['description']&.empty?
			puts "Evento: #{item['name']} - Evento sem descrição raspada".red
			return [false, false]
		end

		event                     = Event.where("(details ->> 'source_url') = ?", item['source_url']).first
		query                     = Base64.encode64(item['description'])
		features_params           = { query: query }
		features_uri              = URI("#{ENV['API_URL']}:5000/event/features")
		features_uri.query        = URI.encode_www_form(features_params)
		features_response         = Net::HTTP.get_response(features_uri)
		@features_response_failed = !features_response.is_a?(Net::HTTPSuccess)

		if event
			puts "#{@events_create_counter}: #{item['name']} - Evento já existe".yellow

			ml_data = JSON.parse(features_response.try(:body))

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

			event.ml_data.deep_merge!(
				cleanned: ml_data['cleanned'],
				stemmed:  ml_data['stemmed'],
				# freq:     ml_data['freq'],
				nouns: ml_data['nouns'],
				verbs: ml_data['verbs'],
				adjs:  ml_data['adjs']
			)

			puts "#{item['name']} - atualizado".white

			[event, ml_data]

		elsif @features_response_failed
			puts "#{@events_create_counter}: #{item['name']} - Evento falhou durante a criação (ML Data)".red

			return [false, false]

		else
			ml_data = JSON.parse(features_response.try(:body))
			event   = Event.new

			puts "#{@events_create_counter}: #{item['name']} - Evento criado".white

			event.details.deep_merge!(
				name:        item['name'],
				description: item['description'],
				source_url:  item['source_url'],
				ticket_url:  item['ticket_url'],
				prices:      item['prices'] || []
			)

			event.ml_data.deep_merge!(
				cleanned: ml_data['cleanned'],
				stemmed:  ml_data['stemmed'],
				# freq:     ml_data['freq'],
				nouns: ml_data['nouns'],
				verbs: ml_data['verbs'],
				adjs:  ml_data['adjs']
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

			[event, ml_data]
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
			event, ml_data = create_event(item)
			place          = create_place(item)
			organizers     = create_organizers(item)

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

			unless event.image_data?
				next unless set_cover(item, event)
			end

			# if event.details_description != item['description']
			classify_event(event, ml_data)
			# end

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
