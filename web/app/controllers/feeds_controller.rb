include Pagy::Backend

class FeedsController < ApplicationController
	before_action :authorize_user, except: [:index, :today, :category, :week, :city, :day]
	before_action :completed_swipable, except: [:today, :category, :week, :city, :day]
	before_action :authorize_current_user, only: %i[suggestions follow news]


	def index
		gon.push({
				         :env             => Rails.env,
				         :user_id         => current_user.try(:id),
				         :user_first_name => current_user.try(:first_name)
		         })

		@collections ||= EventServices::CollectionCreator.new(current_user, params)

		@new_events_today             = Event.where("created_at > ?", DateTime.now - 24.hours)
		@events_this_week             = Event.in_days((DateTime.now.beginning_of_day..(DateTime.now.beginning_of_day + 8)).map(&:to_s))
		@events_in_user_suggestions   = Event.in_user_suggestions(current_user)
		@events_from_following_topics = current_user.try(:events_from_following_topics)
		@favorited_events             = current_user.try(:saved_events)
		@following_users              = User.following_users(current_user)
		@events_from_followed_users   = Event.from_followed_users(current_user)


		if current_user&.sign_in_count.try { |counter| counter >= 2 }
			@collection_new_today = @collections.call(
					{
							identifier: 'new-today',
							events:     @new_events_today
					},
					{
							only_in:           @new_events_today.map(&:id),
							order_by_persona:  false,
							order_by_date:     true,
							in_user_personas:  true,
							not_in_categories: ['curso']
					})
		else
			@collection_new_today = {}
		end


		if current_user&.has_events_suggestions?
			@collection_suggestions = @collections.call(
					{
							identifier: 'user-suggestions',
							events:     @events_in_user_suggestions
					},
					{
							only_in:          @events_in_user_suggestions.map(&:id),
							in_user_personas: false,
							order_by_persona: false,
							order_by_date:    true,
							with_high_score:  true
					}
			)
		else
			@collection_suggestions = {}
		end


		if current_user&.has_following_resources?
			@collection_follow = @collections.call(
					{
							identifier: 'follow',
							events:     @events_from_following_topics
					},
					{
							only_in:          @events_from_following_topics.map(&:id),
							not_in:           (@collection_suggestions.dig(:detail, :init_filters_applyed, :current_events_ids) || []),
							order_by_persona: false,
							order_by_date:    true
					})
		else
			@collection_follow = {}
		end


		if @events_from_followed_users.size > 0
			@collection_following_users = @collections.call(
					{
							identifier: 'following-users',
							events:     @events_from_followed_users
					},
					{
							only_in:          @events_from_followed_users.map(&:id),
							in_user_personas: false,
							order_by_persona: false,
							order_by_date:    true,
							with_high_score:  false,
							not_in_saved:     false
					})
		else
			@collection_following_users = {}
		end


		if @events_this_week.size >= 2
			@collection_week = @collections.call(
					{
							identifier: 'this-week',
							events:     @events_this_week
					},
					{
							only_in:           @events_this_week.map(&:id),
							not_in:            (@collection_suggestions.dig(:detail, :init_filters_applyed, :current_events_ids) || []) | (@collection_follow.dig(:detail, :init_filters_applyed, :current_events_ids) || []),
							in_user_personas:  false,
							order_by_persona:  false,
							order_by_date:     true,
							not_in_categories: ['brecho', 'curso']
					})
		else
			@collection_week = {}
		end


		@items = {
				new_today:        @collection_new_today,
				week:             @collection_week,
				follow:           @collection_follow,
				following_users:  @collection_following_users,
				user_suggestions: @collection_suggestions
		}
	end

	def recent
		@new_events_today = Event.where("created_at > ?", DateTime.now - 24.hours)
		@collection       = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                                    identifier: 'new-today',
				                                                                                    events:     @new_events_today
		                                                                                    },
		                                                                                    {
				                                                                                    only_in:          @new_events_today.map(&:id),
				                                                                                    order_by_persona: true,
				                                                                                    in_user_personas: true,
				                                                                                    with_high_score:  false
		                                                                                    })

		@data = {
				identifier: 'new-today',
				collection: @collection,
				title:      {
						principal: "Adicionados recentemente",
						secondary: "Foram adicionados #{@collection.dig(:detail, :total_events_in_collection)} eventos nas últimas 16 horas que podem te interessar"
				},
				filters:    {
						ocurrences: true,
						kinds:      true,
						categories: true
				}
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
				                                                                                              in_user_personas: false,
				                                                                                              with_high_score:  false,
				                                                                                              limit:            16
		                                                                                              })

		@data = {
				identifier: 'user-suggestions',
				collection: @collection,
				title:      {
						principal: "Indicados para #{current_user.first_name}",
						secondary: "Explore os eventos que indicamos com base no seu gosto pessoal"
				},
				filters:    {
						ocurrences: true,
						kinds:      true,
						categories: true
				}
		}
	end

	def follow
		@events_from_following_topics = current_user.try(:events_from_following_topics)
		@collection                   = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                                                identifier: 'follow',
				                                                                                                events:     @events_from_following_topics
		                                                                                                },
		                                                                                                {
				                                                                                                only_in:          @events_from_following_topics.map(&:id),
				                                                                                                order_by_persona: false,
				                                                                                                order_by_date:    true,
				                                                                                                with_high_score:  false,
				                                                                                                in_user_personas: false,
				                                                                                                limit:            16
		                                                                                                })

		@data = {
				identifier: 'follow',
				collection: @collection,
				title:      {
						principal: "Tópicos que você segue",
						secondary: "Explore os eventos de organizadores, locais e tags que você segue."
				},
				opts:       {
						filters: {
								ocurrences: true,
								kinds:      true,
								categories: true
						}
				}
		}
	end

	def today
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'today-and-tomorrow',
				                                                                              events:     Event.all
		                                                                              }, {
				                                                                              in_days:          [DateTime.now.beginning_of_day.to_s, (DateTime.now + 1).end_of_day.to_s],
				                                                                              in_user_personas: false,
				                                                                              order_by_persona: false,
				                                                                              order_by_date:    true,
				                                                                              with_high_score:  true,
				                                                                              limit:            16
		                                                                              })

		@data = {
				identifier: 'today-and-tomorrow',
				collection: @collection,
				title:      {
						principal: "Eventos em Porto Alegre Hoje e Amanhã",
						secondary: "Explore os #{@collection[:detail][:total_events_in_collection]} eventos que ocorrem hoje e amanhã (#{I18n.l(Date.today, format: :long)} - #{I18n.l(Date.tomorrow, format: :long)}) em Porto Alegre - RS"
				},
				filters:    {
						ocurrences: true,
						kinds:      true,
						categories: true
				}
		}
	end

	def week
		@events_this_week = Event.all
		@collection       = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                                    identifier: 'this-week',
				                                                                                    events:     @events_this_week
		                                                                                    }, {
				                                                                                    only_in:          @events_this_week.map(&:id),
				                                                                                    in_user_personas: false,
				                                                                                    order_by_persona: false,
				                                                                                    order_by_date:    true,
				                                                                                    with_high_score:  true,
				                                                                                    in_days:          (DateTime.now.beginning_of_day..(DateTime.now.beginning_of_day + 8)).map(&:to_s),
				                                                                                    limit:            16
		                                                                                    })

		@props = {

		}

		@data = {
				identifier: 'this-week',
				collection: @collection,
				title:      {
						principal: current_user ? "Acontecendo esta semana" : "Eventos acontecendo esta semana em Porto Alegre",
						secondary: "Explore os #{@collection[:detail][:total_events_in_collection]} eventos que ocorrem hoje (#{I18n.l(Date.today, format: :short)}) até #{I18n.l(Date.today + 6, format: :week)} (#{I18n.l(Date.today + 6, format: :short)}) em Porto Alegre - RS"
				},
				filters:    {
						ocurrences: true,
						kinds:      true,
						categories: true
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
				                                                                              in_user_personas: false,
				                                                                              not_in_saved:     false,
				                                                                              order_by_persona: true,
				                                                                              order_by_date:    false,
				                                                                              with_high_score:  false,
				                                                                              limit:            16
		                                                                              })

		@data = {
				identifier: 'category',
				collection: @collection,
				title:      {
						principal: "Eventos na categoria #{params[:category].try(:capitalize)} em Porto Alegre",
						secondary: "Explore os #{@collection[:detail][:total_events_in_collection]} eventos de #{params[:category]} em Porto Alegre - RS"
				},
				filters:    {
						ocurrences: true,
						kinds:      false,
						categories: false
				}
		}
	end

	def city
		@collection = EventServices::CollectionCreator.new(current_user, params).call({
				                                                                              identifier: 'city',
				                                                                              events:     Event.all
		                                                                              }, {
				                                                                              limit:            16,
				                                                                              in_user_personas: false,
				                                                                              order_by_persona: false,
				                                                                              order_by_date:    true,
				                                                                              with_high_score:  false
		                                                                              })

		@data = {
				identifier: 'city',
				collection: @collection,
				title:      {
						principal: "Eventos em Porto Alegre",
						secondary: current_user ? "Explore todos os eventos ordenados por dia sem filtro de perfil" : "Explore todos os eventos que ocorrem em Porto Alegre - RS"
				},
				filters:    {
						ocurrences: true,
						kinds:      false,
						categories: false
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
				                                                                                      in_user_personas: false,
				                                                                                      order_by_persona: true,
				                                                                                      order_by_date:    false,
				                                                                                      with_high_score:  false,
				                                                                                      limit:            16
		                                                                                      })

		@data = {
				identifier: 'day',
				collection: @collection,
				title:      {
						principal: "Eventos em Porto Alegre que ocorren dia #{I18n.l(@day, format: :long)}",
						secondary: "Acontecem #{@collection[:detail][:total_events_in_collection]} eventos neste dia"
				},
				filters:    {
						ocurrences: true,
						kinds:      true,
						categories: true
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
		if current_user&.need_to_finish_swipable? && !params[:skip_swipable]
			redirect_to onboarding_path
		end
	end


	protected

	def search_params
		params.permit(:categories, :personas, categories: [], personas: [])
	end
end
