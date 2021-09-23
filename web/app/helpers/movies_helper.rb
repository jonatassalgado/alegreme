module MoviesHelper

	def is_new_movie? movie
		movie.created_at > (DateTime.now - 48.hours)
	end

end
