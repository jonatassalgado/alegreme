json.current_user current_user
json.feed @grouped_events do |group, events|
	json.date group
	json.events events do |event|
		json.id event.id
		json.cover_url shrine_image_url(event, :feed)
		json.name event.name
		json.start_time event.start_time
		json.price event.prices.try(:min)
		json.geographic event.geographic
		json.categories event.categories.pluck(:details)
		json.place event.place_details_name
		json.origin_url event_url(event, format: :html)
		json.created_at event.created_at
		json.updated_at event.updated_at
		json.is_new is_new_event?(event)
		json.liked current_user.like?(event) rescue false
	end
end