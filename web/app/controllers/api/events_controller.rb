module Api
	class EventsController < ApplicationController
		before_action :authenticate_user!, except: [:index, :similar_events, :today, :category, :week, :show]
		before_action :set_event, only: [:like, :show]

		def index

		end

		def similar_events

		end

		def today

		end

		def category

		end

		def week

		end

		def show
			begin
				@user           = current_user
				@similar_events = Event.includes(:categories).active.where(id: @event.similar_data).order_by_ids(@event.similar_data).limit(8)
			rescue StandardError => e
				render json: {
					message: e,
					status:  400
				}, status:   :unprocessable_entity
			end
		end

		def like
			begin
				if current_user.like? @event
					current_user.unlike! @event
					render json: { message: 'Evento removido da sua agenda', status: 200 }, status: :created
				elsif current_user.dislike? @event
					current_user.like! @event, action: :update
					render json: { message: 'Evento adicionado na sua agenda', status: 200 }, status: :created
				else
					current_user.like! @event
					render json: { message: 'Evento adicionado na sua agenda', status: 200 }, status: :created
				end
			rescue StandardError => e
				render json: {
					message: e,
					status:  400
				}, status:   :unprocessable_entity
			end
		end

		def liked
			begin
				@user         = current_user
				@liked_events = @user.liked_events_and_screenings&.sort_by { |resource| resource&.start_time }
			rescue StandardError => e
				render json: {
					message: e,
					status:  400
				}, status:   :unprocessable_entity
			end
		end

		def suggestions
			begin
				@user               = current_user
				@events_suggestions = Event.includes(:place, :categories).active.valid.in_user_suggestions(@user).not_liked_or_disliked(@user).limit(5)
			rescue StandardError => e
				render json: {
					message: e,
					status:  400
				}, status:   :unprocessable_entity
			end
		end

		private

		def set_event
			if params[:id].numeric?
				@event = Event.find(params[:id])
			else
				if Event.friendly.exists_by_friendly_id? params[:id]
					@event = Event.friendly.find(params[:id])
				end
			end
		end
	end
end
