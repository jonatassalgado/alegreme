require_relative '../../lib/geographic.rb'

class SetGeolocationJob < ApplicationJob
	queue_as :default

	rescue_from(Exception) do |exception|
		logger.debug exception
	end

	def perform(place_id)
		place   = Place.find place_id
		address = place.geographic['address']
		geocode = Geocoder.search(Geographic.get_cep_from_address(address)).first

		place.geographic.deep_merge!({
				                             latlon:       geocode.try(:coordinates),
				                             neighborhood: geocode.try(:suburb),
				                             city:         address ? address[/Porto Alegre/] : nil,
				                             cep:          Geographic.get_cep_from_address(address),
		                             })

		place.save!
	end
end
