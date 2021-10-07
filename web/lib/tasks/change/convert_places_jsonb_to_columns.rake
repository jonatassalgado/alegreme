require_relative '../../geographic.rb'

namespace :change do
	desc 'Converter jsonb to columns in places '
	task convert_places_jsonb_to_columns: :environment do
		places  = Place.all
		counter = 0

		places.find_each do |place|
			place.name         ||= place.details['name']
			place.address      ||= place.geographic['address']
			place.cep          ||= place.geographic['cep']
			place.city         ||= place.geographic['city']
			place.neighborhood ||= place.geographic['neighborhood']
			place.latitude ||= place.geographic['latlon'][0] rescue nil
			place.longitude ||= place.geographic['latlon'][1] rescue nil

			if place.address != 'Porto Alegre' && place.neighborhood.blank?
				geocode            = Geocoder.search(place.address, params: { countrycodes: 'br' }).first
				place.neighborhood = geocode.try { |geo| geo.address_components_of_type(:sublocality).dig(0, "long_name") } || geocode.try(:neighborhood)
				place.cep          = Geographic.get_cep_from_address(place.address) || geocode.try(:postal_code)

				if place.latitude.blank? || place.longitude.blank?
					place.latitude ||= geocode.try(:coordinates)[0] rescue nil
					place.longitude ||= geocode.try(:coordinates)[1] rescue nil
				end
			end

			if place.save
				counter += 1
				puts "#{counter}: (#{place.id}) Local atualizado -> #{place.address} | #{place.neighborhood} | #{place.latitude} | #{place.longitude}"
			else
				puts "#{counter}: (#{place.id}) Error"
			end
		end
	end
end