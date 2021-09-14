class MoviesComponent < ViewComponent::Base
	def initialize(movies:, user:, title: 'Filmes em Porto Alegre', id: 'movies', chips: false, hovercard: false, template: 'default')
		@movies    = movies
		@user      = user
		@title     = title
		@id        = id
		@chips     = chips
		@hovercard = hovercard
		@template  = template
	end

	def render?
		@movies.present?
	end
end