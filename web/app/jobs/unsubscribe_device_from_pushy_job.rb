require 'net/http'
require 'json'

class UnsubscribeDeviceFromPushyJob < ApplicationJob
	queue_as :default

	rescue_from(Exception) do |exception|
		logger.debug exception
	end

	def perform(device_token)
		uri = URI("https://api.pushy.me/devices/unsubscribe?api_key=#{Rails.application.credentials[Rails.env.to_sym][:pushy][:api_key]}")

		req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
		req.body = {token: device_token}.to_json

		res = Net::HTTP.start(uri.hostname, uri.port) do |http|
		  http.request(req)
		end

		case res
		when Net::HTTPSuccess, Net::HTTPRedirection
		  res.body
		else
		  false
		end
	end
end
