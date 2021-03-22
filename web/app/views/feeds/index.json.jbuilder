grouped_events = @upcoming_events.includes(:categories).limit(50).group_by { |e| e.start_time.strftime("%Y-%m-%d") }

json.feed grouped_events do |group, events|
	json.date group
	json.events events do |event|
		json.id event.id
		json.cover_url shrine_image_url(event, :feed)
		json.name event.details_name
		json.description event.details_description
		json.source_url event.details_source_url
		json.price event.details_prices_min
		json.geographic event.geographic
		json.categories event.categories.pluck(:details)
		json.liked current_user&.like?(event) || false
		json.created_at event.created_at
		json.updated_at event.updated_at
	end
end