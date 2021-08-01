@events = Event.active.in_categories([params[:category]]).order_by_date.includes(:place, :categories)

json.items @events do |event|
	json.name event.name
	json.url event.url
	json.cover shrine_image_url event, :feed
	json.date "#{event.day_of_week['decorator']} #{format_hour event.start_time }"
	json.category event.categories_primary_name
	json.place do
		json.name limit_place_name_size(event.place_details_name, 30)
		json.url place_path event.place
	end
end
