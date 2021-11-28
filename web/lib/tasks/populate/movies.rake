require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'

require_relative '../../../config/initializers/shrine.rb'
require_relative '../../../app/uploaders/movie_image_uploader'

module PopulateMoviesRake

	def create_screenings(item)
		movie = CineFilm.find_by("lower(title) LIKE ?", "#{item['name']&.downcase}%")

		if movie
			set_cover(item, movie) if ENV['update_images'] == 'true'
			movie.update_only_if_blank({
																	 genres:      item['genres'],
																	 description: item['description'],
																	 cover:       item['cover'],
																	 trailer:     item['trailer'],
																	 age_rating:  item['age_rating'],
																	 cast:        item['cast'],
																	 year:        item['year']&.to_i,
																	 rating:      item['rating']&.to_f
																 })
			puts "Filme: #{item['name']} - Filme já existe (atualizado) \n".white
		else
			movie = CineFilm.create!(title:       item['name'],
															 genres:      item['genres'],
															 description: item['description'],
															 cover:       item['cover'],
															 trailer:     item['trailer'],
															 rating:      item['rating']&.to_f,
															 age_rating:  item['age_rating'],
															 cast:        item['cast'],
															 year:        item['year']&.to_i,
															 status:      'active')

			set_cover(item, movie)
			save_movie(movie)
		end

		item['screenings'].each do |screening_data|

			screening_data.dig('places')&.each do |cinema_data|
				cinema = Cinema.find_by(google_id: cinema_data.dig('google_id'))

				if cinema
					puts "Cinema: #{cinema.id} #{cinema.name} - Cinema já existe".white
				else
					cinema = Cinema.create!(name:         cinema_data.dig('name'),
																	display_name: cinema_data.dig('name'),
																	google_id:    cinema_data.dig('google_id'),
																	google_maps:  cinema_data.dig('google_maps'),
																	status:       'active')

					puts "Cinema: #{cinema.id} #{cinema.name} - Cinema criado".green
				end

				screening_group = ScreeningGroup.find_or_create_by(date:      screening_data.dig('date'),
																													 cinema_id: cinema.id,
																													 movie_id:  movie.id)

				cinema_data.dig('languages').each do |language_data|
					screening = Screening.find_by(language:           language_data.dig('name'),
																				screen_type:        handle_empty_screen(language_data),
																				screening_group_id: screening_group.id)
					puts "Grupo: #{screening_group.id} - Grupo #{screening_group.new_record? ? 'criado' : 'já existe'}".green

					if screening
						screening.update(times: language_data.dig('times'))
						puts "Exibição: #{screening.id} #{screening.language} - Exibição já existe - atualizando times #{screening.times}".green
					else
						screening = Screening.create!(times:              language_data.dig('times'),
																					language:           language_data.dig('name'),
																					screen_type:        handle_empty_screen(language_data),
																					screening_group_id: screening_group.id)

						puts "Exibição: #{screening.id} #{screening.language} - Exibição criada - Adicionando ao grupo #{screening.times}".green
					end

				end

			end
		end

	end

	def save_movie(movie)

		if movie.save!
			@movies_create_counter += 1
			puts "Filme: (#{@movies_create_counter}) #{movie.title[0..60]} criado \n".green
			true
		end
	end

	def set_cover(item, movie)
		unless movie
			puts "#{movie.inspect} - Não existe".yellow
		end

		unless item['cover']
			puts "#{item['name']} - Próximo (atributo cover não capturado durante scrapy)".yellow
		end

		begin
			movie_cover_file = Down.download(item['cover'])
		rescue Down::Error => e
			puts "#{item['name']} - Erro no download da imagem (#{item['cover']}) - #{e}".red
			return false
		else
			puts "#{item['name']} - Download da imagem (#{item['cover']}) - Sucesso".blue
		end

		return unless movie_cover_file

		begin
			if movie.image&.present?
				movie.update(image: movie_cover_file)
			else
				movie.image = movie_cover_file
			end
			puts "#{item['name']} - Upload de imagem".blue
		rescue
			puts "#{item['name']} - Erro no upload da image #{e} - #{movie.image.inspect}".red
			return false
		end

		true
	end

	def read_file
		files              = Dir['/var/www/scrapy/data/scraped/*']
		@current_file_name = (files.select { |file| file[/movies-\d{8}-\d{6}\.jsonl$/] }).max

		puts "Lendo arquivo JSON #{@current_file_name}".blue

		@current_file = File.read(@current_file_name)
	end

	def create_artifact
		timestr  = DateTime.now.strftime("%Y%m%d-%H%M%S")
		artifact = Artifact.create(
			details: {
				name: @current_file_name,
				type: 'scraped'
			}
		)
		artifact.file.attach(io: File.open("#{@current_file_name}"), filename: "movies-#{timestr}.jsonl", content_type: "application/json")
	end

	private

	def handle_empty_screen(language_data)
		language_data.dig('screen_type') == 'Nenhuma exibição' ? '2D' : language_data.dig('screen_type')
	end

end

namespace :populate do
	desc 'Populate movies scraped from google. args: update_images=false'
	task movies: :environment do

		include PopulateMoviesRake

		puts "Task populate:movies iniciada em #{DateTime.now}".white

		@last_task_performed = Artifact.where(details: {
			name: "populate:movies",
			type: "task"
		}).first

		# noinspection RubyArgCount
		@uploader               = MovieImageUploader.new(:store)
		@movies_create_counter  = 0
		@events_similar_counter = 0

		read_file

		if @last_task_performed.try { |ltp| ltp.data['last_file_used'] == @current_file_name }
			puts "Task já realizada para o arquivo #{@current_file_name}".yellow
			abort
		end

		create_artifact

		begin
			data = JSONL.parse(@current_file)
		rescue JSON::ParserError => e
			puts "Erro ao ler arquivo JSON: #{e}".red
			return
		else
			puts "Arquivo JSON parseado".blue
		end

		data.each do |item|
			create_screenings(item)
		end

		if @last_task_performed
			@last_task_performed.touch
		else
			Artifact.create(
				details: {
					name: "populate:movies",
					type: "task"
				},
				data:    {
					last_file_used: @current_file_name
				})
		end

		puts "Task populate:movies finalizada em #{DateTime.now}}".white

		if @movies_create_counter == 0
			puts "Nenhum evento criado para o arquivo #{@current_file_name}, abortando próximas tasks...".yellow
			abort
		end

	end
end
