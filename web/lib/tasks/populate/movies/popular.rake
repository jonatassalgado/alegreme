require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'
require 'openssl'


require_relative '../../../../config/initializers/shrine.rb'
require_relative '../../../../app/uploaders/movie_image_uploader'

module PopulateMoviesPopularRake

	def create_movie(item)

		genres = {
			'28' => 'Ação',
    	'12' => 'Aventura',
    	'16' => 'Animação',
    	'35' => 'Comédia',
    	'80' => 'Crime',
    	'99' => 'Documentário',
    	'18' => 'Drama',
    	'10751' => 'Família',
    	'14' => 'Fantasia',
    	'36' => 'História',
    	'27' => 'Terror',
    	'10402' => 'Música',
    	'9648' => 'Mistério',
    	'10749' => 'Romance',
    	'878' => 'Ficção científica',
    	'10770' => 'Cinema TV' ,
    	'53' => 'Thriller',
    	'10752' => 'Guerra',
    	'37' => 'Faroeste'
		}

		movie = Streaming.where.contains(details: {title: item['title']}).first

		if movie
			puts "#{@movies_create_counter}: #{item['name']} - Filme já existe (atualizado)".white
			movie.details.deep_merge!(
				original_title: item['original_title'],
				title:          item['title'],
				genres:         item['genre_ids'].map {|genre| genres[genre.to_s]},
				description:    item['overview'],
				cover:          item['poster_path'],
				popularity:     item['popularity'],
				vote_average:   item['vote_average'],
				adult:          item['adult'],
				tmdb_id:        item['id']
			)

			[movie, :updated]
		else
			movie = Streaming.new
			movie.details.deep_merge!(
				original_title: item['original_title'],
				title:          item['title'],
				genres:         item['genre_ids'].map {|genre| genres[genre.to_s]},
				description:    item['overview'],
				cover:          item['poster_path'],
				popularity:     item['popularity'],
				vote_average:   item['vote_average'],
				adult:          item['adult'],
				tmdb_id:        item['id']
			)

			[movie, :created]
		end
	end


	def save_movie(movie)
		movie.slug = nil

		if movie.save!
			@movies_create_counter += 1
			puts "#{movie.details['title'][0..60]} criado #{@movies_create_counter}".green
			true
		end
	end


	def set_cover(item, movie)
		cover_width = 200

		unless movie
			puts "#{movie.inspect} - Não existe".yellow
		end

		unless item['poster_path']
			puts "#{item['title']} - Próximo (atributo cover não capturado durante scrapy)".yellow
		end

		return true if movie&.image

		begin
			movie_cover_file = Down.download("http://image.tmdb.org/t/p/w#{cover_width}/#{item['poster_path']}")
		rescue Down::Error => e
			puts "#{item['title']} - Erro no download da imagem (#{item['poster_path']}) - #{e}".red
			return false
		else
			puts "#{item['title']} - Download da imagem (#{item['poster_path']}) - Sucesso".blue
		end

		return unless movie_cover_file

		begin
			movie.image = movie_cover_file
			puts "#{item['title']} - Upload de imagem".blue
		rescue
			puts "#{item['title']} - Erro no upload da image #{e} - #{movie.image.inspect}".red
			return false
		end

		true
	end

	def set_trailler(item, movie)
	  google_api_key = Rails.application.credentials[Rails.env.to_sym][:google][:alegreme_api]

	  movie_query    = item['title']
	  max_result     = 1

	  url            = URI("https://www.googleapis.com/youtube/v3/search?part=snippet&regionCode=BR&maxResults=#{max_result}&q=#{ERB::Util.url_encode(movie_query)}%20filme%20trailler&key=#{google_api_key}")

	  http = Net::HTTP.new(url.host, url.port)
	  http.use_ssl = true
	  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

	  request           = Net::HTTP::Get.new(url)
	  request['Accept'] = 'application/json'

	  response = http.request(request)
	  videoId  = JSON.parse(response.read_body)['items'][0]['id']['videoId']

		if videoId
			puts "#{item['title']} - Video de trailler capturado com sucesso".blue
			movie.details_trailler = "https://www.youtube.com/watch?v=#{videoId}"

			return true
		else
			puts "#{item['title']} - Video de trailler não capturado".red
			return false
		end
	end

	def set_streamings(item, movie)
		rapidapi_key  = Rails.application.credentials[Rails.env.to_sym][:rapidapi_key]
		movie_tmdb_id = item['id']
		url           = URI("https://utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com/idlookup?country=BR&source_id=#{movie_tmdb_id}&source=tmdb")

		http             = Net::HTTP.new(url.host, url.port)
		http.use_ssl     = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE

		request                    = Net::HTTP::Get.new(url)
		request["x-rapidapi-host"] = 'utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com'
		request["x-rapidapi-key"]  = rapidapi_key
		request['Accept']          = 'application/json'

		response  = http.request(request)
		locations = JSON.parse(response.read_body).dig('collection', 'locations')

		if locations.present?
			puts "#{item['title']} - Video com #{locations.size} streamings localizados".blue
			movie.streamings = locations

			return true
		else
			puts "#{item['title']} - Video sem streamings localizados".yellow
			return false
		end
	end

	def get_popular_movies(page = 1)
		tmdb_api         = Rails.application.credentials[Rails.env.to_sym][:tmdb_api]
		today            = DateTime.now
		in_last_days     = 30
		min_votes        = 5
		min_vote_average = 4
		url              = URI("https://api.themoviedb.org/3/discover/movie?api_key=#{tmdb_api}&language=pt-BR&sort_by=popularity.desc&include_adult=false&include_video=true&page=#{page}&vote_count.gte=#{min_votes}&vote_average.gte=#{min_vote_average}&release_date.gte=#{(today - in_last_days).strftime('%Y-%m-%d')}&release_date.lte=#{today.strftime('%Y-%m-%d')}")

		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE

		request = Net::HTTP::Get.new(url)

		response = http.request(request)
		@data_from_tmdb = JSON.parse(response.read_body)
	end

end

def populate_movies
	@movies_create_counter = 0
	max_page               = @data_from_tmdb['total_pages'] > 10 ? 5 : @data_from_tmdb['total_pages']
	total_pages            = *(1..max_page)

	total_pages.each do |page|
		get_popular_movies(page)

		@data_from_tmdb["results"].each do |item|
			movie, status = create_movie(item)
			set_streamings(item, movie)
			if status == :created
				next unless set_cover(item, movie)
				set_trailler(item, movie)
			end
			save_movie(movie)
		end

	end
end


namespace :populate do
	namespace :movies do

		desc 'Populate popular movies from tmdb'
		task popular: :environment do |t|

			include PopulateMoviesPopularRake

			puts "Task populate:movies:popular iniciada em #{DateTime.now}".white

			get_popular_movies
			populate_movies

			puts "Task populate:movies finalizada em #{DateTime.now}".white

		end
	end
end
