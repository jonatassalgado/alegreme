class MoviesComponent < ViewComponent::Base
	def initialize(movies:, user:, title: 'Cinemas de Porto Alegre')
		@movies = movies
		@user   = user
		@title  = title
	end

	def render?
		@movies.present?
	end
end