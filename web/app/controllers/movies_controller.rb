class MoviesController < ApplicationController
	# before_action :authorize_admin, only: [:new, :edit, :create, :update, :destroy]

	def index
		@movies = Movie.select("*").from(Movie.select("*, jsonb_array_elements(dates) as date")).where("(date ->> 'date') > ?", DateTime.now.beginning_of_day).uniq
	end

	def show
		@movie = Movie.friendly.find(params[:id])

		respond_to do |format|
			format.html { render :show }
		end
	end
end
