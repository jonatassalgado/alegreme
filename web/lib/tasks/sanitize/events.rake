namespace :sanitize do
	desc 'Sanitize active events'
	task events: :environment do
        event_description_sanitizer = Rails::Html::WhiteListSanitizer.new

		events = Event.active
		counter = 0

		events.find_each do |event|
			next if event.description.blank?
			
            event.description = event_description_sanitizer.sanitize(event.description, :tags => %w(br p a), attributes: %w(href rel target))

			if event.save
				counter += 1
				puts "#{counter}: (#{event.id}) Evento limpo -> #{event.description[0..80]}"
			end
		end

        Rails.cache.clear
	end
end