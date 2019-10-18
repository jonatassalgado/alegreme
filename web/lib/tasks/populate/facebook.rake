require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'

require_relative '../../geographic.rb'
require_relative '../../../config/initializers/shrine.rb'
require_relative '../../../app/uploaders/image_uploader'


namespace :populate do
	desc 'Populate events scraped from facebook'
	task facebook: :environment do
		# noinspection RubyArgCount
		@uploader               = ImageUploader.new(:store)
		@events_create_counter  = 0
		@events_similar_counter = 0

		read_file

		begin
			data = JSONL.parse(@current_file)
		rescue JSON::ParserError => e
			puts "Erro ao ler arquivo JSON: #{e}".red
			return
		else
			puts "Arquivo JSON parseado".blue
		end

		data.each do |item|
			place = create_place(item)

			next unless item['description']

			event, ml_data = create_event(item)

			next unless event
			next unless set_cover(item, event)

			associate_event_place(event, place)
			create_organizer(item, event)
			classify_event(event, ml_data)
			save_event(event)
		end
	end
end

def create_place(item)
	place = Place.where.contains(details: {name: item['place']}).first

	if !place.blank?
		puts "#{place.details['name']} - Lugar já existe".white

		place
	else
		# @geocode = Geocoder.search(Alegreme::Geographic.get_cep_from_address(item['address'])).first if item['address']

		place = Place.new
		place.details.deep_merge!(name: item['place'])
		place.geographic.deep_merge!(
				address: item['address']
		)
		place.slug = nil
		place.save!

		SetGeolocationJob.perform_later(place.id)

		puts "#{place.details_name} - Lugar criado".blue

		place
	end
end

def create_organizer(item, event)
	item['organizers'].try(:each) do |organizer_item|
		organizer = Organizer.where.contains(details: {name: organizer_item}).first

		if !organizer.blank?
			puts "#{organizer.details['name']} - Organizador já existe".yellow
			event.organizers << organizer unless event.organizers.include?(organizer)
		else
			organizer = Organizer.new
			organizer.details.deep_merge!(
					name: organizer_item
			)

			organizer.slug = nil
			organizer.save!

			puts "#{organizer_item} - Organizador criado".blue

			event.organizers << organizer unless event.organizers.include?(organizer)
		end
	end
end

def save_event(event)
	event.slug = nil
	event.save!

	@events_create_counter += 1
	puts "#{event.details['name'][0..60]} criado #{@events_create_counter}".green
end

def classify_event(event, ml_data)
	@label_query  = Base64.encode64(ml_data['stemmed'])
	@label_params = {query: @label_query}

	@label_uri       = URI("#{ENV['API_URL']}:5000/event/label")
	@label_uri.query = URI.encode_www_form(@label_params)

	@label_response = Net::HTTP.get_response(@label_uri)
	@label_data     = JSON.parse(@label_response.try(:body))

	@label_response_is_success = @label_response.is_a?(Net::HTTPSuccess)

	if @label_response_is_success

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
		puts "Erro durante a classificação - #{event.details_name}".red
	end
end

def set_cover(item, event)
	return unless item['cover_url']
	return if event.image

	begin
		event_cover_file = Down.download(item['cover_url'])
	rescue Down::Error => e
		puts "#{item['name']} - Erro no download da imagem (#{item['cover_url']}) - #{e}".red
		return false
	else
		puts "#{item['name']} - Download da imagem (#{item['cover_url']}) - Sucesso".blue
	end

	return unless event_cover_file

	begin
		event.image = event_cover_file
		puts "#{item['name']} - Upload de imagem".blue
	rescue
		puts "#{item['name']} - Erro no upload da image #{e}".red
		return false
	end

	true
end

def associate_event_place(event, place)
	place.events << event unless place.events.include?(event)
end

def read_file
	files     = Dir['/var/www/scrapy/data/scraped/*']
	last_file = (files.select { |file| file[/events-\d{8}-\d{6}\.jsonl$/] }).max

	timestr  = DateTime.now.strftime("%Y%m%d-%H%M%S")
	artifact = Artifact.create(
			details: {
					name: last_file,
					type: 'scraped'
			}
	)

	artifact.file.attach(io: File.open("#{last_file}"), filename: "events-#{timestr}.jsonl", content_type: "application/json")

	puts "Lendo arquivo JSON #{last_file}".blue

	@current_file = File.read(last_file)
end

def create_event(item)
	query                     = Base64.encode64(item['description'])
	features_params           = {query: query}
	features_uri              = URI("#{ENV['API_URL']}:5000/event/features")
	features_uri.query        = URI.encode_www_form(features_params)
	features_response         = Net::HTTP.get_response(features_uri)
	@features_response_failed = !features_response.is_a?(Net::HTTPSuccess)

	event = Event.where.contains(details: {source_url: item['source_url']}).first

	if !event.blank?
		@events_create_counter += 1

		event.details.deep_merge!(
				name:        item['name'].gsub(/[^[$][-]\p{L}\p{M}*+ ]|[+]/i, ''),
				description: item['description'],
				prices:      item['prices'] || []
		)

		event.ocurrences.deep_merge!(
				dates: item['datetimes']
		)

		event.geographic.deep_merge!(
				address:      item['address'],
				# latlon:       @geocode.try(:coordinates),
				# neighborhood: @geocode.try(:suburb),
				city:         item['address'] ? item['address'][/Porto Alegre/] : nil,
				cep:          Alegreme::Geographic.get_cep_from_address(item['address'])
		)

		event.slug = nil
		event.save

		puts "#{@events_create_counter}: #{item['name']} - Evento já existe".white
	elsif @features_response_failed
		@events_create_counter += 1
		puts "#{@events_create_counter}: #{item['name']} - Evento falhou durante a criação".red
	else
		ml_data = JSON.parse(features_response.try(:body))
		event   = Event.new

		event.details.deep_merge!(
				name:        item['name'],
				description: item['description'],
				source_url:  item['source_url'],
				prices:      item['prices'] || []
		)

		event.ml_data.deep_merge!(
				cleanned: ml_data['cleanned'],
				stemmed:  ml_data['stemmed'],
				freq:     ml_data['freq'],
				nouns:    ml_data['nouns'],
				verbs:    ml_data['verbs'],
				adjs:     ml_data['adjs']
		)

		event.ocurrences.deep_merge!(
				dates: item['datetimes']
		)

		event.geographic.deep_merge!(
				address:      item['address'],
				# latlon:       @geocode.try(:coordinates),
				# neighborhood: @geocode.try(:suburb),
				city:         item['address'] ? item['address'][/Porto Alegre/] : nil,
				cep:          Alegreme::Geographic.get_cep_from_address(item['address'])
		)

		[event, ml_data]
	end

end
