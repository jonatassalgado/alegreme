namespace :change do
	desc 'Converter jsonb to columns'
	task convert_details_jsonb: :environment do
		events = Event.all
		counter = 0

		events.find_each do |event|
			next if event.name && !event.datetimes.empty?
			event.name        = event.details['name']
			event.prices      = event.details['prices']
			event.source_url  = event.details['source_url']
			event.ticket_url  = event.details['ticket_url']
			event.description = event.details['description']
			event.datetimes = event.ocurrences['dates'].map{|d| Time.zone.parse(d).to_datetime } rescue []
			if event.save
				counter += 1
				puts "#{counter}: (#{event.id}) Evento atualizado -> #{event.datetimes}"
			end
		end
	end
end