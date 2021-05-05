require 'colorize'

module DuplicatedEventsRake

	def remove_event(event)
		return if event.datetimes.try(:blank?)
		duplicated = Event.kinda_spelled_like(event.name).in_day(event.datetimes.first.to_date).filter{|e| e.created_at > event.created_at}[0]
		if duplicated
			puts "Evento: (#{duplicated.id}) #{duplicated.name} - Evento deletado".yellow
			Event.destroy(duplicated.id)
		else
			puts "Evento: (#{event.id}) #{event.name} - Evento sem duplicação".white
		end
	end

end

namespace :remove do
	desc 'Remove duplicated events'
	task duplicated_events: :environment do

		include DuplicatedEventsRake

		puts "Task remove:duplicated_events iniciada em #{DateTime.now}".white

		events = Event.active

		events.each do |event|
			remove_event(event)
		end

		puts "Task remove:duplicated_events finalizada em #{DateTime.now}".white
	end
end
