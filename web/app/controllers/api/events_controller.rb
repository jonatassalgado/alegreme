module Api
	class EventsController < ApplicationController
		before_action :authenticate_user!, only: [:like, :liked]
		before_action :set_event, only: :like

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

		def like
			begin
				if current_user.like? @event
					current_user.unlike! @event
				elsif current_user.dislike? @event
					current_user.like! @event, action: :update
				else
					current_user.like! @event
				end

				render json: { event: @event.id, status: 200 }, status: :created
			rescue StandardError => e
				render json: {
					error:  "Failed in like event. Error: #{e}",
					status: 400
				}, status:   :unprocessable_entity
			end
		end

		def liked
			begin
				@user = current_user
				@liked_events = @user.liked_events.includes(:place, :organizers, :categories).active.valid.not_ml_data.order_by_date.limit(100)
			rescue StandardError => e
				render json: {
					error:  "Failed request liked events. Error: #{e}",
					status: 400
				}, status:   :unprocessable_entity
			end
		end

		private

		def set_event
			if params[:id].numeric?
				@event = Event.includes(:likes).find(params[:id])
			else
				if Event.friendly.exists_by_friendly_id? params[:id]
					@event = Event.includes(:likes).friendly.find(params[:id])
				end
			end
		end
	end
end
