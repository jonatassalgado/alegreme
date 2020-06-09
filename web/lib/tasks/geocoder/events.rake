require 'colorize'
require 'json'
require 'jsonl'

require_relative '../../geographic.rb'

module GeocoderEventsRake

	def geocode_event(event)
		if event.geographic_latlon.present?
			puts "#{event.details_name} - Geocoder já realizado".yellow
			return false
		end

		@geocode = Geocoder.search(event.geographic_address).first if event.geographic_address

		event.geographic.deep_merge!(
				address:      event.geographic_address,
				latlon:       @geocode.try(:coordinates),
				neighborhood: @geocode.try {|geo| geo.address_components_of_type(:sublocality).try {|comp| comp[0].try {|names| names["long_name"]}}},
				city:         event.geographic_address ? event.geographic_address[/Porto Alegre/] : nil,
				cep:          Alegreme::Geographic.get_cep_from_address(event.geographic_address) || @geocode.try(:postal_code)
		)

		if event.save
			@events_create_counter += 1
			puts "#{@events_create_counter}: #{event.details_name} #{event.geographic_latlon} - Geocoder realizado".white
		else
		  puts "#{event.details_name} - Geocoder não realizado".red
		end
	end

end


namespace :geocoder do
	desc 'Geocode active events'
	task events: :environment do

		include GeocoderEventsRake

		puts "Task geocode:events iniciada em #{DateTime.now}".white

		@events_create_counter = 0
		events = Event.active

		events.each do |event|
			geocode_event event
		end

		puts "Task geocode:events terminada em #{DateTime.now}".white

	end
end
