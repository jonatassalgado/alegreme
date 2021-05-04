favorited_events = Event.select("id, details, ocurrences, image_data").favorited_by(user).active.order_by_date.uniq

json.events favorited_events do |event|
  json.id event.id
  json.name event.name
  json.day_of_week event.day_of_week['decorator']
  json.url event.url
  json.cover_style get_image_style_attr(event)
  json.favorited user.taste_events_saved?(event.id).to_s
end

json.currentEventFavorited currentEventFavorited
