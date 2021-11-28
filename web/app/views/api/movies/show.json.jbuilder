json.id @movie.id
json.name @movie.title
json.cover_url shrine_image_url(@movie, :medium)
json.description @movie.description
json.genres @movie.genres&.join(', ')
json.trailer @movie.trailer
json.rating @movie.rating
json.age_rating @movie.age_rating
json.dominant_color @movie&.image&.dig(:medium)&.metadata&.dig('dominant_color')
json.origin_url movie_url(@movie, format: :html)
json.liked @user ? @user.like?(@movie) : false
json.cinemas @movie.screening_groups&.includes(:screenings)&.active&.sort_by { |sg| sg.cinema&.display_name }&.group_by { |s| [s.cinema&.display_name, s.cinema&.google_id] } do |cinema_name_group|
	json.name cinema_name_group[0][0]
	json.address cinema_name_group[1][0]&.cinema&.address
	json.neighborhood cinema_name_group[1][0]&.cinema&.neighborhood
	json.lower_price cinema_name_group[1][0]&.cinema&.lower_price
	json.google_maps cinema_name_group[1][0]&.cinema&.google_maps
	json.website cinema_name_group[1][0]&.cinema&.website
	json.set! 'session_days', cinema_name_group[1].filter { |sg| sg.date.to_date >= Date.current }.sort_by { |sg | sg.date } do |screening_group|
		json.day screening_group.date
		json.screenings screening_group.screenings.filter { |s| s.times&.any? }.each do |screening|
			json.id screening_group.id
			json.liked @user ? @user.like?(screening_group) : false
			json.language screening.language
			json.screen_type screening.screen_type == 'Nenhuma exibição' ? '2D' : screening.screen_type
			json.times screening.times
		end
	end
end

