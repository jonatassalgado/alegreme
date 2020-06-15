require 'net/http'
require 'openssl'
require 'uri'
require 'json'

task wip: :environment do
  google_api_key = Rails.application.credentials[Rails.env.to_sym][:google][:alegreme_api]

  movie_query    = 'sonic'
  max_result     = 1

  url            = URI("https://www.googleapis.com/youtube/v3/search?part=snippet&regionCode=BR&maxResults=#{max_result}&q=#{ERB::Util.url_encode(movie_query)}%20filme%20trailler&key=#{google_api_key}")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request           = Net::HTTP::Get.new(url)
  request['Accept'] = 'application/json'

  response = http.request(request)

  videoId = JSON.parse(response.read_body)

  ap videoId
end
