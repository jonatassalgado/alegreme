json.current_user @user
json.events @liked_events do |event|
	json.id event.id
	json.cover_url shrine_image_url(event, :feed)
	json.name event.name&.titleize
	json.start_time event.start_time
	json.price event.prices.try(:min)
	json.geographic event.geographic
	json.categories event.categories.pluck(:details)
	json.place event.place_details_name
	json.origin_url event_url(event, format: :html)
	json.multiple_hours event.multiple_hours
	json.updated_at event.updated_at
	json.is_new is_new_event?(event)
	json.liked @user.like?(event) rescue false
end
