module Api
	class MoviesController < ApplicationController
		before_action :authenticate_user!, only: []
		before_action :set_movie, only: [:show]

		def index
			#Timecop.freeze("2021-08-15")
			@movies = CineFilm.active.reverse
		end

		# def like
		# 	begin
		# 		if current_user.like? @event
		# 			current_user.unlike! @event
		# 		elsif current_user.dislike? @event
		# 			current_user.like! @event, action: :update
		# 		else
		# 			current_user.like! @event
		# 		end
		#
		# 		render json: { event: @event.id, status: 200 }, status: :created
		# 	rescue StandardError => e
		# 		render json: {
		# 			error:  "Failed in like event. Error: #{e}",
		# 			status: 400
		# 		}, status:   :unprocessable_entity
		# 	end
		# end
		#
		# def liked
		# 	begin
		# 		@user         = current_user
		# 		@liked_events = @user.liked_events.includes(:place, :categories).active.valid.order_by_date.limit(100)
		# 	rescue StandardError => e
		# 		render json: {
		# 			error:  "Failed request liked events. Error: #{e}",
		# 			status: 400
		# 		}, status:   :unprocessable_entity
		# 	end
		# end

		def show
			#Timecop.freeze("2021-08-15")
			begin
				@user = current_user
			rescue StandardError => e
				render json: {
					error:  "Failed request event. Error: #{e}",
					status: 400
				}, status:   :unprocessable_entity
			end
		end

		private

		def set_movie
			if params[:id].numeric?
				@movie = CineFilm.find(params[:id])
			else
				if CineFilm.friendly.exists_by_friendly_id? params[:id]
					@movie = CineFilm.friendly.find(params[:id])
				end
			end
		end
	end
end
