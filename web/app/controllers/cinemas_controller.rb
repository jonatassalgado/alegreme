class CinemasController < ApplicationController
	before_action :authorize_admin, except: [:index, :show]
	before_action :set_cinema, only: [:show]

	def index
		@cinemas = Cinema.active
	end

	def show
		@movies = Movie.active.where(id: @cinema.movie_ids)
	end

	private

	def set_cinema
		if params[:id].numeric?
			@cinema = Cinema.find(params[:id])
		else
			if Cinema.friendly.exists_by_friendly_id? params[:id]
				@cinema = Cinema.friendly.find(params[:id])
			else
				redirect_to cinema_path
			end
		end
	end

end
