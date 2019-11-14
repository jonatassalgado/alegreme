class SearchController < ApplicationController
	# before_action :authorize_user

	def index

		if params[:q]
			query = params[:q].downcase.split.delete_if { |word| Event::STOPWORDS.include?(word) }.join(' ')

			@events_found = Event.search(query, {
					fields:       ["name^2", "organizers", "description", "category"],
					suggest:      true,
					limit:        150,
					includes:     [:place],
					operator:     "or",
					body_options: {min_score: 10}
			})

			@collection = EventServices::CollectionCreator.new(current_user, params).call({
					                                                                              identifier: 'search',
					                                                                              ids:        @events_found.map(&:id)
			                                                                              },
			                                                                              {
					                                                                              only_in:          @events_found.map(&:id),
					                                                                              in_user_personas: false,
					                                                                              order_by_persona: false,
					                                                                              with_high_score:  false,
					                                                                              order_by_ids:     @events_found.map(&:id),
					                                                                              group_by:         false
			                                                                              })

			@data = {
					identifier: "search",
					collection: @collection,
					title:      {
							principal: "#{@collection.dig(:detail, :total_events_in_collection)} eventos encontrados para \"#{params[:q]}\""
					},
					filters:    {
							ocurrences: true,
							kinds:      true,
							categories: true
					}
			}
		else

		end
	end


	private


	protected

	def search_params
		params.permit(:categories, :personas, categories: [], personas: [])
	end
end
