event          = Event.friendly.find(params[:id])
similar_events = Event.includes(:place).active.where(id: event.similar_data).limit(15)

json.items similar_events do |event|
	json.name event.name
	json.url event.url
end
