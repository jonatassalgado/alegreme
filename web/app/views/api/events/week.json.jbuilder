collection = EventServices::CollectionCreator.new(current_user, params).call({
		                                                                             identifier: 'this-week',
		                                                                             events:     Event.all
                                                                             }, {
		                                                                             limit: 500
                                                                             })

json.items collection[:events] do |event|
	json.name event.details_name
	json.url event.url
	json.cover shrine_image_url event, :feed
	json.date "#{event.day_of_week['decorator']} #{format_hour event.start_time }"
	json.category event.categories_primary_name
	json.place do
		json.name limit_place_name_size(event.place_details_name, 30)
		json.url place_path event.place
	end
end
