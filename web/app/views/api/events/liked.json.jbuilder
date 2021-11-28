json.events @liked_events do |resource|
	json.id resource.id
	json.cover_url resource.is_a?(Event) ? shrine_image_url(resource, :feed) : shrine_image_url(resource, :medium)
	json.name resource.name
	json.start_time resource.start_time
	json.price resource.prices&.min
	json.geographic resource.geographic
	json.categories resource.categories&.pluck(:details)
	json.place resource.place_name
	json.origin_url event_url(resource, format: :html)
	json.multiple_hours resource.multiple_hours
	json.updated_at resource.updated_at
	json.is_new resource.is_a?(ScreeningGroup) ? is_new_screening?(resource) : is_new_event?(resource)
	json.liked @user ? @user.like?(resource) : false
	json.type resource.class.name.underscore

	# movie
	json.movie_id resource.movie_id if resource.is_a?(ScreeningGroup)
	json.times resource.screenings.map(&:times).flatten.uniq if resource.is_a?(ScreeningGroup)
	json.trailer resource.trailer if resource.is_a?(ScreeningGroup)
	json.genres resource.genres&.join(', ') if resource.is_a?(ScreeningGroup)
	json.trailer resource.trailer if resource.is_a?(ScreeningGroup)
	json.rating resource.rating if resource.is_a?(ScreeningGroup)
	json.age_rating resource.age_rating if resource.is_a?(ScreeningGroup)
	json.cinema_display_name resource.cinema_display_name if resource.is_a?(ScreeningGroup)
end
