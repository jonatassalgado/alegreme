class SearchController < ApplicationController
	# before_action :authorize_user

	def index
		gon.push(:user => current_user)
		gon.push(:env => Rails.env)

		query = params[:q].downcase.split.delete_if { |word| Event::STOPWORDS.include?(word) }.join(' ')

		@events_found = Event.search(query, {
				fields:       ["name^2", "organizers", "description", "category"],
				suggest:      true,
				limit:        150,
				includes:     [:place],
				operator:     "or",
				body_options: {min_score: 100}
		})

		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'search',
				                                                                              ids:        @events_found.map(&:id)
		                                                                              },
		                                                                              {
				                                                                              only_in:           @events_found.map(&:id),
				                                                                              with_high_score:   false,
				                                                                              order_by_personas: false,
				                                                                              order_by_date:     false,
				                                                                              order_by_ids:      @events_found.map(&:id),
				                                                                              group_by:          false
		                                                                              })

		@locals = {
				items:      @collection,
				title:      {
						principal: "Eventos encontrados para \"#{params[:q]}\""
				},
				identifier: "search",
				opts:       {
						filters: {
								ocurrences: true,
								kinds:      true,
								categories: true
						},
						detail:  @collection[:detail]
				}
		}
	end


	private


	protected

	def search_params
		params.permit(:categories, :personas, categories: [], personas: [])
	end
end
