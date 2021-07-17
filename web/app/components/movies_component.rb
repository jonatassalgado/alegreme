class MoviesComponent < ViewComponent::Base
	def initialize(movies:, user:, title: 'Cinemas de Porto Alegre', id: 'movies', selected: '')
		@movies   = movies
		@user     = user
		@title    = title
		@id       = id
		@selected = selected
	end

	def render?
		@movies.present?
	end
end