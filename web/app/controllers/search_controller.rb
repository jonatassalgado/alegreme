class SearchController < ApplicationController
	# before_action :authorize_user

	def index

		if params[:q]
			query = params[:q].downcase.split.delete_if { |word| Event::STOPWORDS.include?(word) }.join(' ')

			results = Event.pagy_search(query, {
				fields:        ["name^2", "organizers", "description", "category"],
				suggest:       true,
				limit:         150,
				includes:      [:place, :organizers, :categories],
				operator:      "or",
				body_options:  { min_score: 10 },
				scope_results: ->(r) { r.active }
			})
			# results         = Event.active.includes(:place).limit(42)
			@pagy, @founded_events = pagy_searchkick(results, items: 16)
			@liked_events          = current_user&.liked_events&.not_ml_data&.active&.order_by_date || Event.none
		else
			@categories = Category.select("categories.id, categories.details, COUNT(events.id) as active_events_count").joins(:events).where("events.datetimes[1] > ?", DateTime.now).group("categories.id")
		end

		render layout: false if @stimulus_reflex

		respond_to do |format|
			format.turbo_stream
			format.html
		end
	end

	private

	def search_params
		params.permit(:categories, :personas, categories: [], personas: [])
	end
end
