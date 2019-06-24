class FeedsController < ApplicationController
	before_action :authorize_admin, only: [:train]

	def index
		respond_to do |format|
			format.js do
				Rails.cache.fetch("#{current_or_guest_user}_user_personas", expires_in: 1.hour) do
					collection = EventServices::CollectionCreator.new(current_or_guest_user, params)
					@items     = collection.call(params[:identifier])
				end

				@locals = {
						items:      @items,
						titles:     {
								principal: params[:title]
						},
						identifier: params[:identifier],
						type:       :large,
						filters:    @items[:filters]
				}

				render 'collections/index'
			end

			format.html do
				gon.user_id = current_user.try(:token) || current_or_guest_user.try(:id) || 'null'
				collections ||= EventServices::CollectionCreator.new(current_or_guest_user, params)

				@items = if params[:q]
					         get_events_for_search_query
					       else
						       {
								       today: collections.call('today-and-tomorrow', group_by: 5),
								       # cinema: collections.events_for_cinema(group_by: 10),
								       # show_and_party: collections.events_for_show_and_party(group_by: 5),
								       user_personas: collections.call('user-personas', all_existing_filters: true)
						       }
				         end

				@favorited_events = current_or_guest_user.favorited_events
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
