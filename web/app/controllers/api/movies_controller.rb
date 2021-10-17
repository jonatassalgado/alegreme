module Api
	class MoviesController < ApplicationController
		# before_action :authenticate_user!, except: [:index, :show]
		before_action :set_movie, only: [:show]
		before_action :set_screening, only: [:like]

		def index
			@user   = current_user
			@movies = CineFilm.select("movies.*, COUNT(screenings.id) as screenings_count").joins(:screenings).group('movies.id').order('screenings_count ASC')
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
					if current_user.like? @screening
						current_user.unlike! @screening
						render json: { message: 'Filme removido da sua agenda', status: 200 }, status: :created
					elsif current_user.dislike? @screening
						current_user.like! @screening, action: :update
						render json: { message: 'Filme adicionado na sua agenda', status: 200 }, status: :created
					else
						current_user.like! @screening
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

		def set_screening
			if params[:id].numeric?
				@screening = Screening.find(params[:id])
			else
				if Screening.friendly.exists_by_friendly_id? params[:id]
					@screening = Screening.friendly.find(params[:id])
				end
			end
		end

	end
end
