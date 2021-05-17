@active_events = Event.offset(params[:offset] || 0).includes(:place).order("created_at DESC").limit(1000)

json.array! @active_events.each do |event|
    json.id event.id
    json.data do
        json.cover_url shrine_image_url(event, :feed)
        json.description event.description || ""
        json.place event.place_details_name
        json.created_at event.created_at
    end
end