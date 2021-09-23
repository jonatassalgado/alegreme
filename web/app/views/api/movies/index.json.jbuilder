json.array! @movies do |movie|
	json.id movie.id
	json.name truncate movie.title, length: 20
	json.cover_url shrine_image_url(movie, :medium)
	json.description truncate movie.description, length: 140
	json.genres movie.genres&.join(', ')
	json.trailer movie.trailer
	json.rating movie.rating
	json.age_rating movie.age_rating
	json.dominant_color movie.image&.dig(:medium)&.metadata&.dig('dominant_color')
	json.origin_url movie_url(movie, format: :html)
	json.is_new is_new_movie?(movie) rescue false
	json.liked @user.like?(movie) rescue false
end