include Pagy::Backend

class TrainController < ApplicationController
	before_action :authorize_admin

	def index
		if params[:q]
			query = params[:q].downcase.split.delete_if { |word| Event::STOPWORDS.include?(word) }.join(' ')

			@events = Event.search(query, {
																			fields:       ["name^2", "organizers", "description", "category"],
																			suggest:      true,
																			limit:        150,
																			includes:     [:place],
																			operator:     "or",
																			body_options: {min_score: 100}
																		})

		else
			events_not_trained_yet = get_events_not_trained_yet
			@pagy, @events         = pagy(events_not_trained_yet, items: 6)
		end
	end

	private

	def get_events_not_trained_yet
		if params[:desc]
			Event.where("(theme ->> 'name') IS NULL AND length((details ->> 'description')) > 200")
				.order("(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric DESC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric DESC")
				.includes(:place)
		elsif params[:name]
				Event.where("(theme ->> 'name') IS NULL AND length((details ->> 'description')) > 200 AND (details ->> 'name') LIKE ?", "%#{params[:name]}%")
					.order("(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric ASC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric ASC")
					.includes(:place)
		elsif params[:category]
			Event.where("(theme ->> 'name') IS NULL AND length((details ->> 'description')) > 200 AND (ml_data -> 'categories' -> 'primary' ->> 'name') = ?", params[:category])
				.order("(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric ASC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric ASC")
				.includes(:place)
		elsif params[:place]
			place = Place.friendly.find(params[:place])

			place.events.where("(theme ->> 'name') IS NULL AND length((details ->> 'description')) > 200")
				.order("(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric ASC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric ASC")
				.includes(:place)
		else
			Event.where("(theme ->> 'name') IS NULL AND length((details ->> 'description')) > 200")
				.order("(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric ASC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric ASC")
				.includes(:place)
		end


	end

end
