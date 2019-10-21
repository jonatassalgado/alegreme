include Pagy::Backend

class FeedsController < ApplicationController
	before_action :authorize_user, except: [:today, :category, :week]
	before_action :completed_swipable, except: [:today, :category, :week]


	def index
		gon.push({
				         :env             => Rails.env,
				         :user_id         => current_user.id,
				         :user_first_name => current_user.first_name
		         })

		collections ||= EventServices::CollectionCreator.new(current_user, params)

		collection_week = collections.call(
				{
						identifier: 'this-week',
						events:     Event.all
				},
				{
						group_by: 2
				})

		collection_suggestions = collections.call(
				{
						identifier: 'user-suggestions',
						events:     Event.all
				}
		)

		collection_follow = collections.call(
				{
						identifier: 'follow',
						events:     Event.all
				},
				{
						not_in: collection_week.dig(:detail, :init_filters_applyed, :current_events_ids) | collection_suggestions.dig(:detail, :init_filters_applyed, :current_events_ids)
				})

		collection_personas = collections.call(
				{
						identifier: 'user-personas',
						events:     Event.all
				},
				{
						not_in: collection_follow.dig(:detail, :init_filters_applyed, :current_events_ids) | collection_week.dig(:detail, :init_filters_applyed, :current_events_ids) | collection_suggestions.dig(:detail, :init_filters_applyed, :current_events_ids)
				})

		collection_explorer = collections.call(
				{
						identifier: 'explorer',
						events:     Event.all
				}, {
						user:             current_user,
						order_by_persona: true,
						limit:            12,
						not_in:           collection_follow.dig(:detail, :init_filters_applyed, :current_events_ids) | collection_personas.dig(:detail, :init_filters_applyed, :current_events_ids) | collection_suggestions.dig(:detail, :init_filters_applyed, :current_events_ids)
				}
		)

		@items = {
				week:             collection_week,
				follow:           collection_follow,
				user_personas:    collection_personas,
				user_suggestions: collection_suggestions,
				explorer:         collection_explorer
		}


		@favorited_events = current_or_guest_user.saved_events

	end


	def today
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'today-and-tomorrow',
				                                                                              events:     Event.all
		                                                                              }, {
				                                                                              in_days:         [DateTime.now.beginning_of_day.to_s, (DateTime.now + 1).end_of_day.to_s],
				                                                                              with_high_score: false,
				                                                                              limit:           100
		                                                                              })

		@locals = {
				items:      @collection,
				title:      {
						principal: "Eventos em Porto Alegre Hoje e Amanhã",
						secondary: "Explore os #{@collection[:detail][:total_events_in_collection]} eventos que ocorrem hoje e amanhã (#{I18n.l(Date.today, format: :long)} - #{I18n.l(Date.tomorrow, format: :long)}) em Porto Alegre - RS"
				},
				identifier: 'today-and-tomorrow',
				opts:       {
						filters: {
								ocurrences: true,
								kinds:      true,
								categories: true
						},
						detail:  @collection[:detail],
				}
		}
	end

	def week
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'this-week',
				                                                                              events:     Event.all
		                                                                              }, {
				                                                                              limit: 40
		                                                                              })

		@locals = {
				items:      @collection,
				title:      {
						principal: "Eventos acontecendo esta semana em Porto Alegre",
						secondary: "Explore os #{@collection[:detail][:total_events_in_collection]} eventos que ocorrem hoje (#{I18n.l(Date.today, format: :short)}) até #{I18n.l(Date.today + 6, format: :week)} (#{I18n.l(Date.today + 6, format: :short)}) em Porto Alegre - RS"
				},
				identifier: 'this-week',
				opts:       {
						filters: {
								ocurrences: true,
								kinds:      true,
								categories: true
						},
						detail:  @collection[:detail],
				}
		}
	end

	def category
		@categories = Event::CATEGORIES.dup
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'category',
				                                                                              events:     Event.all
		                                                                              }, {
				                                                                              in_categories:   [params[:category]],
				                                                                              with_high_score: true,
				                                                                              limit:           60
		                                                                              })

		@locals = {
				items:      @collection,
				title:      {
						principal: "Eventos na categoria #{params[:category].capitalize} em Porto Alegre",
						secondary: "Explore os #{@collection[:detail][:total_events_in_collection]} eventos de #{params[:category]} em Porto Alegre - RS"
				},
				identifier: 'category',
				opts:       {
						filters: {
								ocurrences: true,
								kinds:      true,
								categories: true
						},
						detail:  @collection[:detail],
				}
		}
	end

	private

	def get_events_not_trained_yet
		order = params[:desc] ? "(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric DESC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric DESC" : "(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric ASC, (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric ASC"

		Event.where("(theme ->> 'name') IS NULL AND length((details ->> 'description')) > 200")
				.order(order)
				.includes(:place)
	end

	def completed_swipable
		if current_user.need_to_finish_swipable?
			redirect_to onboarding_path
		end
	end


	protected

	def search_params
		params.permit(:categories, :personas, categories: [], personas: [])
	end
end
