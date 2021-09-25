module MoviesHelper

	def is_new_movie? movie
		movie.created_at > (DateTime.now - 5.days) rescue false
	end

end
