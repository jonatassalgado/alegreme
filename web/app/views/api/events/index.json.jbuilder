json.items Event.active.includes(:place) do |event|
	json.name event.details_name
	json.source event.details_source_url
end
