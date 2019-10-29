require 'net/http'
require 'json'

task wip: :environment do
  uri = URI("https://api.pushy.me/devices/unsubscribe?api_key=#{Rails.application.credentials[Rails.env.to_sym][:pushy][:api_key]}")

  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = {token: "REMOVED"}.to_json

  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
    http.request(req)
  end

  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    puts res.body
  else
    puts res.body
  end
end
