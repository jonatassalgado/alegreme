@active_events = Event.where("id >= ? AND id <= ?", params.fetch(:gte, 0), params.fetch(:lte, 1_000_000)).includes(:place).order("created_at DESC")

json.array! @active_events.each do |event|
    json.data do
        json.ref_id event.id
        json.name event.name || ""
        json.description event.description || ""
        json.place event.place_details_name
        json.cover_url shrine_image_url(event, :feed)
        json.created_at event.created_at
    end
end