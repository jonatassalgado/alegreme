include Pagy::Backend

class FeedsController < ApplicationController
	before_action :authorize_user, except: [:today, :category, :week, :city, :day]
	before_action :completed_swipable, except: [:today, :category, :week, :city, :day]
	before_action :authorize_current_user, only: %i[suggestions follow]


	def index
		gon.push({
				         :env             => Rails.env,
				         :user_id         => current_user.id,
				         :user_first_name => current_user.first_name
		         })

		@collections ||= EventServices::CollectionCreator.new(current_user, params)

		@new_events_today           = Event.where("created_at > ?", DateTime.now.beginning_of_day - 1)
		@events_this_week           = Event.in_days((DateTime.now.beginning_of_day..(DateTime.now.beginning_of_day + 8)).map(&:to_s))
		@events_in_user_suggestions = Event.in_user_suggestions(current_user)
		@events_followed_by_user    = Event.follow_features_by_user(current_user)
		@favorited_events           = current_or_guest_user.saved_events


		if current_user.sign_in_count >= 2
			@collection_new_today = @collections.call(
					{
							identifier: 'new-today',
							events:     @new_events_today
					},
					{
							only_in:           @new_events_today.map(&:id),
							order_by_persona:  true,
							in_user_personas:  true,
							not_in_categories: ['curso']
					})
		end

		if @events_this_week.size >= 2
			@collection_week = @collections.call(
					{
							identifier: 'this-week',
							events:     @events_this_week
					},
					{
							only_in:           @events_this_week.map(&:id),
							in_user_personas:  true,
							order_by_persona:  true,
							not_in_categories: ['brecho', 'curso']
					})
		end


		if current_user&.has_events_suggestions?
			@collection_suggestions = @collections.call(
					{
							identifier: 'user-suggestions',
							events:     @events_in_user_suggestions
					},
					{
							only_in:          @events_in_user_suggestions.map(&:id),
							order_by_persona: false,
							order_by_date:    true
					}
			)
		else
			@collection_suggestions = {}
		end


		if current_user&.has_following_resources?
			@collection_follow = @collections.call(
					{
							identifier: 'follow',
							events:     @events_followed_by_user
					},
					{
							only_in:          @events_followed_by_user.map(&:id),
							not_in:           (@collection_suggestions.dig(:detail, :init_filters_applyed, :current_events_ids) || []),
							order_by_persona: false,
							order_by_date:    true
					})
		else
			@collection_follow = {}
		end


		@items = {
				new_today:        @collection_new_today,
				week:             @collection_week,
				follow:           @collection_follow,
				user_suggestions: @collection_suggestions
		}
	end

	def suggestions
		@events_in_user_suggestions = Event.in_user_suggestions(current_user)
		@collection                 = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                                              identifier: 'user-suggestions',
				                                                                                              events:     @events_in_user_suggestions
		                                                                                              },
		                                                                                              {
				                                                                                              only_in:          @events_in_user_suggestions.map(&:id),
				                                                                                              order_by_persona: false,
				                                                                                              order_by_date:    true,
				                                                                                              limit:            48
		                                                                                              })

		@locals = {
				items:      @collection,
				title:      {
						principal: "Indicados para #{current_user.first_name}",
						secondary: "Explore os eventos que indicamos com base no seu gosto pessoal"
				},
				identifier: 'user-suggestions',
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

	def follow
		@events_followed_by_user = Event.follow_features_by_user(current_user)
		@collection              = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                                           identifier: 'follow',
				                                                                                           events:     @events_followed_by_user
		                                                                                           },
		                                                                                           {
				                                                                                           only_in:          @events_followed_by_user.map(&:id),
				                                                                                           order_by_persona: false,
				                                                                                           order_by_date:    true,
				                                                                                           with_high_score:  false,
				                                                                                           limit:            48
		                                                                                           })

		@locals = {
				items:      @collection,
				title:      {
						principal: "Tópicos que você segue",
						secondary: "Explore os eventos de organizadores, locais e tags que você segue."
				},
				identifier: 'follow',
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

	def today
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'today-and-tomorrow',
				                                                                              events:     Event.all
		                                                                              }, {
				                                                                              in_days:         [DateTime.now.beginning_of_day.to_s, (DateTime.now + 1).end_of_day.to_s],
				                                                                              with_high_score: false,
				                                                                              limit:           48
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
		@events_this_week = Event.in_days((DateTime.now.beginning_of_day..(DateTime.now.beginning_of_day + 8)).map(&:to_s))
		@collection       = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                                    identifier: 'this-week',
				                                                                                    events:     @events_this_week
		                                                                                    }, {
				                                                                                    only_in:          @events_this_week.map(&:id),
				                                                                                    in_user_personas: false,
				                                                                                    order_by_persona: true,
				                                                                                    limit:            48
		                                                                                    })

		@locals = {
				items:      @collection,
				title:      {
						principal: current_user ? "Acontecendo esta semana" : "Eventos acontecendo esta semana em Porto Alegre",
						secondary: "Explore os #{@collection[:detail][:total_events_in_collection]} eventos que ocorrem hoje (#{I18n.l(Date.today, format: :short)}) até #{I18n.l(Date.today + 6, format: :week)} (#{I18n.l(Date.today + 6, format: :short)}) em Porto Alegre - RS"
				},
				identifier: 'this-week',
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

	def category
		@categories = Event::CATEGORIES.dup
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'category',
				                                                                              events:     Event.all
		                                                                              }, {
				                                                                              in_categories:    [params[:category]],
				                                                                              order_by_persona: true,
				                                                                              limit:            60
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

	def city
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'city',
				                                                                              events:     Event.all
		                                                                              }, {
				                                                                              limit:            24,
				                                                                              order_by_persona: true,
				                                                                              with_high_score:  true
		                                                                              })

		@locals = {
				items:      @collection,
				title:      {
						principal: "Eventos em Porto Alegre",
						secondary: "Explore todos os eventos que ocorrem em Porto Alegre - RS"
				},
				identifier: 'city',
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

	def day
		@day                = Date.parse params[:day]
		@events_in_this_day = Event.in_days([@day.beginning_of_day.to_s])
		@collection         = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                                      identifier: 'day',
				                                                                                      events:     @events_in_this_day
		                                                                                      }, {
				                                                                                      only_in:          @events_in_this_day.map(&:id),
				                                                                                      order_by_persona: true,
				                                                                                      limit:            12
		                                                                                      })

		@locals = {
				items:      @collection,
				title:      {
						principal: "Eventos em Porto Alegre que ocorren dia #{I18n.l(@day, format: :short)}",
						secondary: "Explore todos os eventos que ocorrem em Porto Alegre - RS no dia #{I18n.l(@day, format: :long)}"
				},
				identifier: 'day',
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
