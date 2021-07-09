require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'

require_relative '../../../config/initializers/shrine.rb'
require_relative '../../../app/uploaders/movie_image_uploader'

module PopulateMoviesRake

	def create_movie(item)
		movie = Movie.find_by(title: item['name'])

		if item['dates'].blank?
			puts "#{@movies_create_counter}: #{item['name']} - Evento sem data raspada".red
			return false
		end

		if movie
			movie.title       = item['name']
			movie.genres      = item['genre']
			movie.description = item['description']
			movie.cover       = item['cover']
			movie.trailer     = item['trailer']
			movie.dates       = item['dates']
			puts "#{@movies_create_counter}: #{item['name']} - Filme já existe (atualizado)".white
		else
			movie             = Movie.new
			movie.title       = item['name']
			movie.genres      = item['genre']
			movie.description = item['description']
			movie.cover       = item['cover']
			movie.trailer     = item['trailer']
			movie.dates       = item['dates']
		end

		movie.type = 'CineFilm'

		movie
	end

	def save_movie(movie)

		if movie.save!
			@movies_create_counter += 1
			puts "#{movie.title[0..60]} criado #{@movies_create_counter}".green
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

		return true if movie&.image

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

end

namespace :populate do
	desc 'Populate movies scraped from google'
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

			movie = create_movie(item)

			unless set_cover(item, movie)
				next
			end

			save_movie(movie)
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
