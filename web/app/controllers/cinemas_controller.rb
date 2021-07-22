class CinemasController < ApplicationController
	before_action :authorize_admin, except: [:index, :show]
	before_action :set_cinema, only: [:show]

	def index
		@cinemas = Cinema.all.order("display_name ASC")
	end

	def show

	end

	private

	def set_cinema
		if params[:id].numeric?
			@cinema = Cinema.includes(movies: :screenings).find(params[:id])
		else
			if Cinema.friendly.exists_by_friendly_id? params[:id]
				@cinema = Cinema.includes(movies: :screenings).friendly.find(params[:id])
			else
				redirect_to cinema_path
			end
		end
	end

end
