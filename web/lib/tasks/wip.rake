
require 'colorize'
require 'json'
require 'open-uri'
require 'net/http'
require 'down'
require 'jsonl'

task wip: :environment do
	# label_query  = Base64.encode64(ml_data['stemmed'])
	label_query = "Feira Vegana de rua com samba grátis e cerveja"
	label_params = { "query" => label_query }

	label_uri       = URI("#{ENV['API_URL']}:5000/event/label")
	# label_uri.query = URI.encode_www_form(label_params)

	label_response = Net::HTTP.post_form(label_uri, label_params)
	label_data     = JSON.parse(label_response.try(:body))

	puts [label_response.is_a?(Net::HTTPSuccess), label_data]
end
