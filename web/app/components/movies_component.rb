class MoviesComponent < ViewComponent::Base
	def initialize(movies:, user:, title: 'Filmes em cartaz', id: 'movies', chips: false)
		@movies = movies
		@user   = user
		@title  = title
		@id     = id
		@chips  = chips
	end

	def render?
		@movies.present?
	end
end