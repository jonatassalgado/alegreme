module Api

	class CollectionsController < ApplicationController

		def index
			collection_creator = EventServices::CollectionCreator.new(current_user, params[:data])

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
						identifier:   params[:data][:identifier],
						collection:   collection,
						title:        {
								principal: place.details_name,
								secondary: place.geographic_address
						},
						followable:   place,
						filters:      collection[:filters],
						origin:       params[:data][:origin],
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
						identifier:   params[:data][:identifier],
						collection:   collection,
						title:        {
								principal: organizer.details_name
						},
						followable:   organizer,
						filters:      collection[:filters],
						origin:       params[:data][:origin],
						json_request: true
				}
			else
				collection = collection_creator.call({
						                                     identifier: params[:data][:identifier],
						                                     events:     Event.all
				                                     })


				@data = {
						identifier:   params[:data][:identifier],
						collection:   collection,
						title:        {
								principal: JSON.parse(params[:data][:title])['principal'],
								secondary: JSON.parse(params[:data][:title])['secondary'].try(:html_safe),
								tertiary:  JSON.parse(params[:data][:title])['tertiary'],
						},
						filters:      collection[:filters],
						origin:       params[:data][:origin],
						similar:      params[:data][:similar],
						continue_to:  params[:data][:continue_to_path],
						insert_after: params[:data][:insert_after],
						json_request: true
				}

				@props = {
						infinite_scroll: params[:props][:infinite_scroll],
						disposition:     params[:props][:disposition]
				}

			end

			respond_to do |format|
				format.js { render 'collections/collection' }
			end
		end

		private

		def initial_filters_applyed
			JSON.parse(params[:data][:init_filters_applyed])
		end


	end
end
