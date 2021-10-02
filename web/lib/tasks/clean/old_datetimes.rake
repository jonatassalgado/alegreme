namespace :clean do
	desc 'Remove old datetimes from events'
	task old_datetimes: :environment do
		Event.active.each do |event|
			cleanned_datetimes = event.datetimes.map(&:to_datetime).reject { |d| d < DateTime.now - 2.hours }
			event.datetimes    = cleanned_datetimes
			event.save!

			puts "Event #{event.id} cleanned. New datetimes #{cleanned_datetimes}"
		end
	end
end