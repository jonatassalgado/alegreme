json.array! @events_suggestions do |event|
	json.id event.id
	json.cover_url shrine_image_url(event, :feed)
	json.name event.name
	json.start_time event.start_time
	json.price event.prices.try(:min)
	json.geographic event.geographic
	json.categories event.categories.pluck(:details)
	json.place event.place_details_name
	json.origin_url event_url(event, format: :html)
	json.is_new is_new_event?(event)
	json.liked @user.like?(event) rescue false
end