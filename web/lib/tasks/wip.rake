require 'net/http'
require 'openssl'
require 'uri'
require 'json'

task wip: :environment do
  tmdb_api         = Rails.application.credentials[Rails.env.to_sym][:tmdb_api]
  today            = DateTime.now
  in_last_days     = 30
  min_votes        = 2
  min_vote_average = 3
  url              = URI("https://api.themoviedb.org/3/discover/movie?api_key=#{tmdb_api}&language=pt-BR&sort_by=popularity.desc&include_adult=false&include_video=true&page=1&vote_count.gte=#{min_votes}&vote_average.gte=#{min_vote_average}&primary_release_date.gte=#{(today - in_last_days).strftime('%Y-%m-%d')}&primary_release_date.lte=#{today.strftime('%Y-%m-%d')}")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url)

  response = http.request(request)
  @data_from_tmdb = JSON.parse(response.read_body)["results"]
  ap @data_from_tmdb
end
