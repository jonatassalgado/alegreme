module Api
	class MoviesController < ApplicationController
		# before_action :authenticate_user!, except: [:index, :show]
		before_action :set_movie, only: [:show]
		before_action :set_screening_group, only: [:like]

		def index
			@user   = current_user
			@movies = CineFilm.active
		end

		def show
			begin
				@user = current_user
			rescue StandardError => e
				render json: {
					message: e,
					status:  400
				}, status:   :unprocessable_entity
			end
		end

		def like
			if current_user
				begin
					if current_user.like? @screening_group
						current_user.unlike! @screening_group
						render json: { message: 'Filme removido da sua agenda', status: 200 }, status: :created
					elsif current_user.dislike? @screening_group
						current_user.like! @screening_group, action: :update
						render json: { message: 'Filme adicionado na sua agenda', status: 200 }, status: :created
					else
						current_user.like! @screening_group
						render json: { message: 'Filme adicionado na sua agenda', status: 200 }, status: :created
					end
				rescue StandardError => e
					logger.debug e

					render json: {
						message: e,
						status:  422
					}, status:   :unprocessable_entity
				end
			else
				render json: {
					message: 'Você precisa entrar para salvar filmes',
					status:  401
				}, status:   :unauthorized
			end
		end

		# def liked
		# 	begin
		# 		@user         = current_user
		# 		@liked_events = @user.liked_events.includes(:place, :categories).active.valid.order_by_date.limit(100)
		# 	rescue StandardError => e
		# 		render json: {
		# 			message:  "Failed request liked events. message: #{e}",
		# 			status: 400
		# 		}, status:   :unprocessable_entity
		# 	end
		# end

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

		def set_screening_group
			@screening_group = ScreeningGroup.find(params[:id])
		end

	end
end
