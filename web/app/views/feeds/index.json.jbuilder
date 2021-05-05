grouped_events = @upcoming_events.includes(:categories).limit(100).group_by { |e| e.start_time.strftime("%Y-%m-%d") }

json.feed grouped_events do |group, events|
	json.date group
	json.events events do |event|
		json.id event.id
		json.cover_url shrine_image_url(event, :feed)
		json.name event.name
		# json.description event.description
		json.start_time event.start_time.strftime('%Y-%m-%d %H:%M:%S')
		json.price event.prices.try(:min)
		json.geographic event.geographic
		json.categories event.categories.pluck(:details)
		json.liked current_user&.like?(event) || false
		json.place event.place_details_name
		# json.source_url event.source_url
		json.origin_url event_url(event, format: :html)
		# json.created_at event.created_at
		json.updated_at event.updated_at
	end
end