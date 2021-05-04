json.items Event.active.includes(:place) do |event|
	json.name event.name
	json.source event.source_url
end
