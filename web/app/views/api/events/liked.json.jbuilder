json.events @liked_events do |resource|
	json.id resource.id
	json.movie_id resource.movie_id if resource.is_a?(Screening)
	json.cover_url resource.is_a?(Event) ? shrine_image_url(resource, :feed) : shrine_image_url(resource, :medium)
	json.name resource.name
	json.start_time resource.start_time
	json.times resource.times if resource.is_a?(Screening)
	json.price resource.prices&.min
	json.geographic resource.geographic
	json.categories resource.categories&.pluck(:details)
	json.place resource.place_details_name
	json.origin_url event_url(resource, format: :html)
	json.multiple_hours resource.multiple_hours
	json.updated_at resource.updated_at
	json.is_new resource.is_a?(Screening) ? is_new_screening?(resource) : is_new_event?(resource)
	json.liked @user.like?(resource) rescue false
	json.type resource.class.name.underscore
end
