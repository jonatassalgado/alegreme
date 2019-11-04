collection = EventServices::CollectionCreator.new(current_user, params).call({
		                                                                                       identifier: 'today-and-tomorrow',
		                                                                                       events:     Event.all
                                                                                       }, {
		                                                                                       in_days: [DateTime.now.beginning_of_day.to_s, (DateTime.now + 1).end_of_day.to_s],
		                                                                                       limit:   100
                                                                                       })

json.items collection[:events] do |event|
	json.name event.details_name
	json.url event.url
	json.cover get_original_image_url event
	json.date "#{event.day_of_week['decorator']} #{format_hour event.first_day_time }"
	json.category event.categories_primary_name
	json.place do
		json.name limit_place_name_size(event.place_details_name, 30)
		json.url place_path event.place
	end
end
