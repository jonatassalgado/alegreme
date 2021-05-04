require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'
require "google/cloud/vision"

module PopulatePostersRake

	def save_poster
		if @poster.save!
			@posters_create_counter += 1
			puts "Poster: #{@poster.id}, #{@poster.details['shortcode']} - Salvo!".green
			true
		end
	end

	# def classify_poster(event, ml_data)
	# 	@label_query  = Base64.encode64(ml_data['stemmed'])
	# 	@label_params = { query: @label_query }

	# 	@label_uri       = URI("#{ENV['API_URL']}:5000/event/label")
	# 	@label_uri.query = URI.encode_www_form(@label_params)

	# 	@label_response = Net::HTTP.get_response(@label_uri)
	# 	@label_data     = JSON.parse(@label_response.try(:body))

	# 	@label_response_is_success = @label_response.is_a?(Net::HTTPSuccess)

	# 	if @label_response_is_success
	# 		puts "Evento: #{event.name} - Adicionando classificação".white
	# 		event.ml_data.deep_merge!(
	# 			personas:   {
	# 				primary:   {
	# 					name:  @label_data['classification']['personas']['primary']['name'],
	# 					score: @label_data['classification']['personas']['primary']['score']
	# 				},
	# 				secondary: {
	# 					name:  @label_data['classification']['personas']['secondary']['name'],
	# 					score: @label_data['classification']['personas']['secondary']['score']
	# 				},
	# 				outlier:   false
	# 			},
	# 			categories: {
	# 				primary:   {
	# 					name:  @label_data['classification']['categories']['primary']['name'],
	# 					score: @label_data['classification']['categories']['primary']['score']
	# 				},
	# 				secondary: {
	# 					name:  @label_data['classification']['categories']['secondary']['name'],
	# 					score: @label_data['classification']['categories']['secondary']['score']
	# 				},
	# 				outlier:   false
	# 			}
	# 		)

	# 		if @label_data['classification']['categories']
	# 			labels = @label_data['classification']['categories']

	# 			categories = Category.where("(details ->> 'name') IN (:categories)", categories: [labels['primary']['name'], labels['secondary']['name']])
	# 			event.categories << categories
	# 		end

	# 	else
	# 		puts "Evento: #{event.name} - Erro durante a classificação".red
	# 	end
	# end

	

	def read_file
		files              = Dir['/var/www/scrapy/data/scraped/*']
		@current_file_name = (files.select { |file| file[/posters-\d{8}-\d{6}\.jsonl$/] }).max

		if @current_file_name.nil?
			puts "Não foi encontrado nenhum arquivo na pasta /scraped".white
			abort
		end

		puts "Lendo arquivo JSON #{@current_file_name} da pasta /scraped".white

		@current_file = File.read(@current_file_name)
	end

	def create_poster(item)
		if item['caption'].blank?
			puts "Poster: #{item['shortcode']} - Poster sem caption raspada".red
			return false
		end

		if item['media'].blank?
			puts "Poster: #{item['shortcode']} - Poster sem media raspada".red
			return false
		end

		poster = Poster.find_by("(details ->> 'source_url') = ?", item['source_url'])
	
		if poster
			puts "#{@posters_create_counter}: #{item['name']} - Poster já existe".yellow

			poster.details.deep_merge!(
				'shortcode'          => item['shortcode'],
				'caption'            => item['caption'],
				'taken_at_timestamp' => item['taken_at_timestamp'],
				'source_url'         => item['source_url']
			)

			poster.owner = item['owner']
			poster.media = item['media']

			puts "#{item['shortcode']} - atualizado".white

			poster

		else
			poster  = Poster.new

			poster.details.deep_merge!(
				'shortcode'          =>  item['shortcode'],
				'caption'            => item['caption'],
				'taken_at_timestamp' => item['taken_at_timestamp'],
				'source_url'         => item['source_url']
			)

			poster.owner = item['owner']
			poster.media = item['media']

			# poster.ocurrences.deep_merge!(
			# 	dates: item['datetimes']
			# )

			# poster.geographic.deep_merge!(
			# 	address:      item['address'],
			# 	latlon:       @geocode.try(:coordinates),
			# 	neighborhood: @geocode.try { |geo| geo.address_components_of_type(:sublocality)[0]["long_name"] },
			# 	city:         item['address'] ? item['address'][/Porto Alegre/] : nil,
			# 	cep:          Geographic.get_cep_from_address(item['address'])
			# )

			puts "#{@posters_create_counter}: #{item['shortcode']} - Poster criado".white

			poster
		end
	end

	def extract_features_from_caption
		query                     = Base64.encode64(@poster.details['caption'])
		features_params           = { query: query }
		features_uri              = URI("#{ENV['API_URL']}:5000/event/features")
		features_uri.query        = URI.encode_www_form(features_params)
		features_response         = Net::HTTP.get_response(features_uri)

		if features_response.is_a?(Net::HTTPSuccess)
			puts "Features extraidas com sucesso"
		else
			puts "#{@posters_create_counter}: #{@poster.details['shortcode']} - Poster falhou durante a criação (ML Data)".red

			return false
		end

		ml_data = JSON.parse(features_response.try(:body))

		@poster.ml_data.deep_merge!(
			'cleanned' => ml_data['cleanned'],
			'stemmed'  => ml_data['stemmed'],
			'nouns'    => ml_data['nouns'],
			'verbs'    => ml_data['verbs'],
			'adjs'     => ml_data['adjs']
		)

		true
	end

	def extract_text_from_media
		begin
			image_annotator = Google::Cloud::Vision.image_annotator
			response        = image_annotator.text_detection(image: @poster.media[0]['display_url'], max_results: 1)
			
			if response.responses[0].text_annotations.blank?
				puts "Imagem sem texto para ser extraido".yellow	
				return false
			else
				extracted_text = response.responses[0].text_annotations[0].description
			end
		rescue => exception
			puts "Erro ao extrair texto de midias - #{exception}".red
			return false
		else
			if extracted_text.blank?
				puts "Não foi extraído texto de midias".yellow
				return false
			else
				puts "Texto extraido de midias com sucesso".white
				@poster.ml_data.deep_merge!(
					'media' => [
						{ 'extracted_data' => extracted_text }
					]
				)
				return true
			end
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

		artifact.file.attach(io: File.open("#{@current_file_name}"), filename: "posters-#{timestr}.jsonl", content_type: "application/json")
	end
end

namespace :populate do
	desc 'Populate posters scraped from instagram'
	task posters: :environment do

		include PopulatePostersRake

		puts "Task populate:posters iniciada em #{DateTime.now}".white

		last_task_performed = Artifact.find_by(details: {
			name: "populate:posters",
			type: "task"
		})

		# noinspection RubyArgCount
		@posters_create_counter  = 0
		@posters_similar_counter = 0

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
			@poster = create_poster(item)
			extract_features_from_caption
			extract_text_from_media
			# classify_poster(event, ml_data)

			unless @poster
				puts "#{item['shortcode']} - Próximo (poster não criado)".yellow
				next
			end

			save_poster
		end

		if last_task_performed
			last_task_performed.touch
		else
			Artifact.create(
				details: {
					name: "populate:posters",
					type: "task"
				},
				data:    {
					last_file_used: @current_file_name
				})
		end

		puts "Task populate:posters finalizada em #{DateTime.now}}".white

		if @posters_create_counter == 0
			puts "Nenhum poster criado para o arquivo #{@current_file_name}, abortando próximas tasks...".yellow
			abort
		end
	end
end
