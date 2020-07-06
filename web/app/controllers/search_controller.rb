class SearchController < ApplicationController
	# before_action :authorize_user

	def index

		if params[:q]
			query = params[:q].downcase.split.delete_if { |word| Event::STOPWORDS.include?(word) }.join(' ')

			@events = Event.search(query, {
					fields:       ["name^2", "organizers", "description", "category"],
					suggest:      true,
					limit:        150,
					includes:     [:place],
					operator:     "or",
					body_options: {min_score: 10}
			})

			@collection = {
					identifier:       'search',
					events:           @events,
					title:            {
							principal: "Eventos encontrados para \"#{params[:q]}\""
					},
					infinite_scroll:  true,
					display_if_empty: true,
					show_similar_to:  session[:show_similar_to]
			}
		else
			@categories = Event::CATEGORIES.dup.delete_if { |category| ['anúncio', 'outlier', 'protesto'].include? category }
		end
	end


	private


	protected

	def search_params
		params.permit(:categories, :personas, categories: [], personas: [])
	end
end
