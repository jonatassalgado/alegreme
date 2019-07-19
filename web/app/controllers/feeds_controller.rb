class FeedsController < ApplicationController

	before_action :authorize_admin, only: [:train]

	def index
		respond_to do |format|
			format.js do
				Rails.cache.fetch("#{current_or_guest_user}_user_personas", expires_in: 1.hour) do
					collection = EventServices::CollectionCreator.new(current_or_guest_user, params)
					@title     = JSON.parse(params[:title])
					@events    = collection.call(params[:identifier])
				end

				@locals = {
						items:      @events,
						title:      {
								principal: @title['principal'],
								secondary: @title['secondary'].try(:html_safe)
						},
						identifier: params[:identifier],
						type:       :large,
						filters:    @events[:filters],
						detail:     @events[:detail]
				}


				render 'collections/index'
			end

			format.html do
				gon.user_id = current_user.try(:token) || current_or_guest_user.try(:id) || 'null'
				collections ||= EventServices::CollectionCreator.new(current_or_guest_user, params)

				@items = if params[:q]
					         get_events_for_search_query
					       else
						       collection_today = collections.call(
								       'today-and-tomorrow',
								       {
										       group_by: 5
								       })

						       collection_follow = collections.call(
								       {
										       identifier: 'follow',
										       collection: current_or_guest_user.events_from_following_features
								       },
								       {
										       not_in: collection_today[:detail][:init_filters_applyed][:events_ids]
								       })

						       collection_personas = collections.call(
								       'user-personas',
								       {not_in: collection_follow[:detail][:init_filters_applyed][:events_ids]
								       })

						       collection_suggestions = collections.call(
								       'user-suggestions',
								       {})

						       {
								       today:            collection_today,
								       follow:           collection_follow,
								       user_personas:    collection_personas,
								       user_suggestions: collection_suggestions
						       }
				         end

				@favorited_events = current_or_guest_user.saved_events
			end
		end

	end

	def train
		events_not_trained_yet = get_events_not_trained_yet

		@items = {
				events:      events_not_trained_yet.limit(20),
				total_count: events_not_trained_yet.count
		}
	end

	private

	def get_events_not_trained_yet
		Event.where("(theme ->> 'name') IS NULL AND length((details ->> 'description')) > 200")
				.order("(categories -> 'primary' ->> 'score')::numeric  ASC, (personas -> 'primary' ->> 'score')::numeric ASC")
				.includes(:place)
	end

	def get_events_for_search_query
		{
				user: Event.search(params[:q].downcase, highlight: true, limit: 23, includes: [:place])
		}
	end

	protected

	def search_params
		params.permit(:categories, :personas, categories: [], personas: [])
	end
end
