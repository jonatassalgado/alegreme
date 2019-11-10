module Api

	class CollectionsController < ApplicationController

		def index
			collection_creator = EventServices::CollectionCreator.new(current_user, params)

			if !initial_filters_applyed['in_places'].blank?
				place  = Place.friendly.find(initial_filters_applyed['in_places'][0])
				events = place.events.active

				collection = collection_creator.call({
						                                     identifier: 'places',
						                                     events:     events
				                                     },
				                                     {
						                                     in_places: initial_filters_applyed['in_places']
				                                     })

				@data = {
						identifier:   params[:identifier],
						collection:   collection,
						title:        {
								principal: place.details_name,
								secondary: place.geographic_address
						},
						followable:   place,
						filters:      collection[:filters],
						detail:       collection[:detail],
						origin:       params[:origin],
						json_request: true
				}
			elsif !initial_filters_applyed['in_organizers'].blank?
				organizer = Organizer.friendly.find(initial_filters_applyed['in_organizers'][0])
				events    = organizer.events.active

				collection = collection_creator.call({
						                                     identifier: 'organizers',
						                                     events:     events},
				                                     {
						                                     in_organizers: initial_filters_applyed['in_organizers']
				                                     })

				@data = {
						identifier:   params[:identifier],
						collection:   collection,
						title:        {
								principal: organizer.details_name
						},
						followable:   organizer,
						filters:      collection[:filters],
						detail:       collection[:detail],
						origin:       params[:origin],
						json_request: true
				}
			else
				collection = collection_creator.call({
						                                     identifier: params[:identifier],
						                                     events:     Event.all
				                                     })


				@data = {
						identifier:   params[:identifier],
						collection:   collection,
						title:        {
								principal: JSON.parse(params[:title])['principal'],
								secondary: JSON.parse(params[:title])['secondary'].try(:html_safe)
						},
						filters:      collection[:filters],
						origin:       params[:origin],
						detail:       collection[:detail],
						similar:      params[:similar],
						json_request: true
				}

			end


			render 'collections/index'
		end

		private

		def initial_filters_applyed
			JSON.parse(params[:init_filters_applyed])
		end


	end
end

