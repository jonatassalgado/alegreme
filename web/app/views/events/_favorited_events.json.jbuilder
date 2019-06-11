favorited_events = Event.select("id, details, ocurrences, image_data").favorited_by(user).active.order_by_date.uniq

json.events favorited_events do |event|
  json.id event.id
  json.name event.details_name
  json.day_of_week event.day_of_week
  json.url event.url
  json.cover_url get_image_style_attr(event)
  json.favorited user.taste_events_saved?(event.id).to_s
end

json.currentEventFavorited currentEventFavorited
