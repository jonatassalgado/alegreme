include Pagy::Backend

class TrainController < ApplicationController
	before_action :authorize_admin

	def index
		events_not_trained_yet = get_events_not_trained_yet

		@pagy, @events = pagy(events_not_trained_yet, items: 6)
	end

	private

	def get_events_not_trained_yet
		order = params[:desc] ? "(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric DESC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric DESC" : "(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric ASC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric ASC"

		Event.where("(theme ->> 'name') IS NULL AND length((details ->> 'description')) > 200")
				.order(order)
				.includes(:place)

		# Event.all.order("updated_at DESC")
	end

end
