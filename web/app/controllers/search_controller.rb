class SearchController < ApplicationController
	before_action :authorize_user

	def index
		gon.push(:user => current_or_guest_user)
		gon.push(:env => Rails.env)


		events      = Event.search(params[:q].downcase, fields: ["name^5", "organizers^3", "place^2", "description", "category"], limit: 40, includes: [:place])
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'search',
				                                                                              ids:        events.map(&:id)
		                                                                              },
		                                                                              {
				                                                                              only_in: events.map(&:id)
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
