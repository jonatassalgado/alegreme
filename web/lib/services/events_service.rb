# noinspection ALL
module EventsService
	class Collection
		@user  = nil
		@events = {}
		@kinds = Event.active.map(&:kinds_name).flatten.sort.uniq.freeze

		class << self
			attr_accessor :user, :events, :kinds
		end

		def initialize(current_user, request_params)
			EventsService::Collection.user ||= current_user

			@params = request_params
			@today = Date.current
			@tomorrow = @today + 1
		end

		def events_for_today(opts = {})
			user, categories, dates, group_by, kinds, sockets = get_params(:today_and_tomorrow, opts)
			events                                            = Event.active
					                                                    .in_theme([], 'not_in': ['educação', 'saúde', 'alimentação'])
					                                                    .in_days(dates)
					                                                    .for_user(user)
					                                                    .by_category(categories, 'primary', 'not_in': ['curso'], 'group_by': group_by, 'turn_on': sockets[:by_category])
					                                                    .with_kinds(kinds)
					                                                    .order_by_persona(user.personas_name)
					                                                    .limit(set_limit(opts))
					                                                    .includes(:place)

			mount_response(events)
		end

		# TODO: Investigar por que nao vem eventos tipo Festaaa underground
		def events_for_user_personas(opts = {})
			user, categories, dates, group_by, kinds, sockets = get_params(:user_personas, opts)
			events                                            = Event.active
					                                                    .in_theme([], 'not_in': ['false'])
					                                                    .in_days(dates)
					                                                    .by_category(categories, 'primary', 'group_by': group_by, 'turn_on': sockets[:by_category], 'personas': user.personas_name)
					                                                    .with_kinds(kinds)
					                                                    .order_by_persona(user.personas_name)
					                                                    .order_by_date
					                                                    .limit(set_limit(opts))
					                                                    .includes(:place)

			mount_response(events)
		end

		def events_for_cinema(opts = {})
			user, categories, dates, group_by, _kinds = get_params(:cinema, opts)
			events                                    = Event.active
					                                            .in_theme(['lazer', 'cultura', 'educação'])
					                                            .for_user(user)
					                                            .in_days(dates)
					                                            .by_category(categories, 'primary', 'not_in': ['curso'], 'group_by': group_by)
					                                            .order_by_persona(user.personas_name)
					                                            .order_by_date
					                                            .limit(set_limit(opts))
					                                            .includes(:place)

			mount_response(events)
		end

		# noinspection RubyInstanceMethodNamingConvention
		def events_for_show_and_party(opts = {})
			user, categories, dates, group_by, _kinds = get_params(:show_and_party, opts)
			events                                    = Event.active
					                                            .in_theme([], 'not_in': ['educação', 'saúde', 'alimentação'])
					                                            .for_user(user)
					                                            .in_days(dates)
					                                            .by_category(categories, 'primary', 'not_in': ['curso'], 'group_by': group_by)
					                                            .order_by_persona(user.personas_name)
					                                            .order_by_date
					                                            .limit(set_limit(opts))
					                                            .includes(:place)

			mount_response(events)
		end

		private

		def get_current_user
			EventsService::Collection.user
		end

		def set_limit(opts)
			opts.fetch(:limit, 10)
		end

		def get_params(identifier, opts)
			user       = get_current_user
			categories = set_initial_categories_filter(identifier, opts)
			dates      = set_initial_dates_filter(identifier, opts)
			kinds      = set_initial_kinds_filter(identifier, opts)
			group_by   = calculate_items_for_group(identifier, opts)
			sockets    = get_sockets_status(identifier, opts)
			[user, categories, dates, group_by, kinds, sockets]
		end

		def get_sockets_status(identifier, opts)
			if group_by_or_kinds_not_exist?(opts)
				{by_category: true}
			else
				{by_category: false}
			end
		end

		def group_by_or_kinds_not_exist?(opts)
			@params[:categories] || (!opts[:group_by].blank? || @params[:kinds].blank?)
		end

		def mount_response(events)
			{
					events:     events,
					categories: get_filters_from_exist_events(events, 'categories'),
					kinds:      get_filters_from_exist_events(events, 'kinds'),
					ocurrences: get_filters_from_exist_events(events, 'ocurrences')
			}
		end

		def set_initial_categories_filter(identifier, opts)
			default_categories = {
					today_and_tomorrow: ['teatro', 'festa', 'show', 'feira', 'fórum', 'cinema', 'brecho', 'meetup', 'sarau', 'slam', 'exposição', 'palestra', 'literatura'],
					show_and_party:     ['show', 'festa'],
					cinema:             ['cinema', 'teatro'],
					user_personas:      ['festa', 'curso', 'teatro', 'show', 'cinema', 'exposição', 'feira', 'esporte', 'meetup', 'hackaton', 'palestra', 'sarau', 'festival', 'brecho', 'fórum', 'slam',]
			}

			@params[:categories] || opts.fetch(:categories, default_categories[identifier])
		end

		def set_initial_kinds_filter(identifier, opts)
			default_kinds = {
					today_and_tomorrow: [],
					show_and_party:     [],
					cinema:             [],
					user_personas:      EventsService::Collection.kinds
			}

			@params[:kinds] || opts.fetch(:kinds, default_kinds[identifier])
		end

		def set_initial_dates_filter(identifier, opts)
			default_dates = {
					today_and_tomorrow: [@today.to_s, @tomorrow.to_s],
					show_and_party:     [],
					cinema:             [],
					user_personas:      []
			}

			@params[:ocurrences] || opts.fetch(:ocurrences, default_dates[identifier])
		end

		def calculate_items_for_group(identifier, opts)
			if params_filter_category_exist?
				categories = @params.fetch(:categories, [])
				categories.count < 5 ? (10 / categories.count) : 2
			elsif params_filter_kind_exist?
				10
			elsif identifier == :today_and_tomorrow
				opts.fetch(:group_by, 5)
			else
				opts.fetch(:group_by, 2)
			end
		end

		def get_filters_from_exist_events(events, type)
			if params_filters_exist?
				defaults = JSON.parse @params[:defaults]

				case type
				when 'categories'
					defaults[type]
				when 'kinds'
					if params_filter_category_exist?
						events.map(&:kinds_name).flatten.uniq
					else
						defaults[type]
					end
				when 'ocurrences'
					if params_filter_category_exist? || params_filter_kind_exist?
						Event.day_of_week(events).sort_by_original.values.uniq
					else
						defaults[type]
					end
				end
			else
				case type
				when 'categories'
					events.map(&:categories_primary_name).uniq
				when 'kinds'
					events.map(&:kinds_name).flatten.uniq
				when 'ocurrences'
					Event.day_of_week(events).sort_by_original.values.uniq
				end
			end
		end

		def get_events_from_cache
			EventsService::Collection.events[@params[:section]]
		end

		def add_events_to_cache(events, opts = {})
			EventsService::Collection.events[@params[:section]] = events
		end

		def params_filter_category_exist?
			!@params[:categories].blank?
		end

		def params_filter_kind_exist?
			!@params[:kinds].blank?
		end

		def params_filters_exist?
			!@params[:categories].blank? || !@params[:kinds].blank? || !@params[:ocurrences].blank?
		end
	end
end
