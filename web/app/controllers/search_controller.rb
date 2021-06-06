class SearchController < ApplicationController
	# before_action :authorize_user

	def index

		if params[:q]
			query = params[:q].downcase.split.delete_if { |word| Event::STOPWORDS.include?(word) }.join(' ')

			@search_result  = Event.search(query, {
				fields:        ["name^2", "organizers", "description", "category"],
				suggest:       true,
				limit:         150,
				includes:      [:place],
				operator:      "or",
				body_options:  { min_score: 10 },
				scope_results: ->(r) { r.active }
			})
			# @search_result  = Event.active.not_ml_data.includes(:place).order_by_date
			@founded_events = Event.includes(:place, :organizers, :categories).where(id: @search_result.map(&:id)).not_ml_data
			@liked_events   = current_user&.liked_events&.not_ml_data&.active&.order_by_date || Event.none
		else
			@categories = Event::CATEGORIES.dup.delete_if { |category| ['anúncio', 'outlier', 'protesto'].include? category }
		end

		render layout: false if @stimulus_reflex
	end

	private

	protected

	def search_params
		params.permit(:categories, :personas, categories: [], personas: [])
	end
end
