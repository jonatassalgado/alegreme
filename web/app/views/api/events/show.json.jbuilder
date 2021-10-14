json.id @event.id
json.cover_url shrine_image_url(@event, :original)
json.name limit_name_size(@event.name)
json.description @event.description
json.start_time @event.start_time
json.price @event.prices.try(:min)
json.place @event.place_name
json.geographic({ "address": @event.place_address })
json.categories @event.categories.pluck(:details)
json.source_url @event.source_url
json.origin_url event_url(@event, format: :html)
json.ticket_url @event.ticket_url
json.multiple_hours @event.multiple_hours
json.created_at @event.created_at
json.updated_at @event.updated_at
json.is_new is_new_event?(@event)
json.liked @user ? @user.like?(@event) : false
json.similar @similar_events do |similar|
	json.id similar.id
	json.cover_url shrine_image_url(similar, :feed)
	json.name similar.name&.titleize
	json.start_time similar.start_time
	json.place similar.place_name
	json.geographic similar.geographic
	json.categories similar.categories.pluck(:details)
	json.multiple_hours similar.multiple_hours
	json.updated_at similar.updated_at
end
