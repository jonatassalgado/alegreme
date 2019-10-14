# noinspection ALL
module EventServices
	class CollectionCreator
		class << self
			attr_accessor :user, :active_events, :categories, :kinds, :default_filters
		end

		def initialize(current_user, request_params = {})
			cache_variables(current_user)

			@params               = request_params || {}
			@today                = DateTime.now.beginning_of_day
			@tomorrow             = @today + 1
			@init_filters_applyed = @params[:init_filters_applyed] ? JSON.parse(@params[:init_filters_applyed]) : {}
		end

		def call(collection, opts = {})
			raise ArgumentError, "Coleção precisa ser um Hash com eventos e identificador" unless collection.is_a? Hash

			if collection.key?(:events)
				@identifier = collection[:identifier]
				@events     = collection[:events]
			elsif collection.key?(:ids)
				@identifier = collection
				@events     = Event.where(id: [collection[:ids]])
			end

			@opts            = default_options(opts)
			@dynamic_filters = default_filters.merge(get_filters_for_collection)
			@all_events      = EventFetcher.new(@events, @dynamic_filters).call

			mount_response
		end


		private

		def default_filters
			{
					user:              get_current_user,
					in_categories:     set_initial_categories_filter,
					not_in_categories: set_not_in_categories,
					in_days:           set_initial_dates_filter,
					in_kinds:          set_initial_kinds_filter,
					in_organizers:     set_initial_organizers_filter,
					in_places:         set_initial_places_filter,
					order_by_date:     set_order_by_date,
					order_by_persona:  set_order_by_persona,
					group_by:          set_group_by,
					not_in:            set_not_in,
					only_in:           set_only_in,
					with_high_score:   set_high_score,
					limit:             set_limit
			}
		end

		def get_filters_for_collection
			collections = {
					'today-and-tomorrow' => {
							in_days: @params[:ocurrences] || [DateTime.now.beginning_of_day.to_s, (DateTime.now + 1).end_of_day.to_s]
					},
					'this-week'          => {
							in_days:          @params[:ocurrences] || (@today..(@today + 6)).map(&:to_s),
							in_user_personas: false,
							order_by_persona: true,
							group_by:         calculate_items_for_group(nil, auto_balance: false)
					},
					'follow'             => {
							in_days:            set_initial_dates_filter,
							order_by_persona:   false,
							in_follow_features: true,
							group_by:           nil
					},
					'user-suggestions'   => {
							in_user_suggestions: true,
							in_days:             set_initial_dates_filter,
							order_by_persona:    true,
							group_by:            calculate_items_for_group(nil, auto_balance: false)
					},
					'user-personas'      => {
							in_user_personas: CollectionCreator.user,
							in_days:          set_initial_dates_filter,
							order_by_persona: true,
							group_by:         calculate_items_for_group(2, auto_balance: true),
							limit:            40
					}
			}

			if collections.key?(@identifier)
				collections[@identifier]
			else
				{}
			end
		end

		def default_options(opts)
			default_opts = {
					'today-and-tomorrow' => {
							limit: 36
					},
					'this-week'          => {
							all_existing_filters: false,
							limit:                8
					},
					'user-personas'      => {
							all_existing_filters: false,
							limit:                8
					},
					'follow'             => {
							all_existing_filters: false,
							limit:                8
					},
					'user-suggestions'   => {
							all_existing_filters: false,
							limit:                8
					}
			}

			if default_opts.key?(@identifier)
				default_opts[@identifier].merge(opts)
			else
				{
						all_existing_filters: false,
						limit:                8
				}.merge(opts)
			end
		end

		def get_filters_toggle_for_collection
			filters = {
					'this-week'        => {
							categories: true,
							kinds:      true,
							ocurrences: true
					},
					'user-personas'    => {
							categories: true,
							kinds:      true,
							ocurrences: true
					},
					'follow'           => {
							categories: true,
							kinds:      true,
							ocurrences: true
					},
					'user-suggestions' => {
							categories: true,
							kinds:      true,
							ocurrences: true
					}
			}

			filters[@identifier] || {
					categories: true,
					kinds:      true,
					ocurrences: true
			}
		end

		def mount_response
			@current_events = @all_events.limit(@params[:limit] || @opts[:limit])

			{
					events:     @current_events,
					categories: get_filters_from_exist_events(@all_events, 'categories'),
					kinds:      get_filters_from_exist_events(@all_events, 'kinds'),
					ocurrences: get_filters_from_exist_events(@all_events, 'ocurrences'),
					filters:    get_filters_toggle_for_collection,
					detail:     {
							total_events_in_collection:  @all_events.length,
							actual_events_in_collection: @current_events.length,
							init_filters_applyed:        filters_without_sensitive_info
					}
			}
		end

		def get_current_user
			CollectionCreator.user
		end

		def set_limit
			false
		end

		def group_by_or_kinds_not_exist?(opts)
			@params[:categories] || (!opts[:group_by].blank? || @params[:kinds].blank?)
		end

		def set_initial_categories_filter
			@params[:categories] || @opts[:categories] || []
		end

		def set_initial_kinds_filter
			@params[:kinds] || @opts[:kinds] || []
		end

		def set_initial_dates_filter
			# if params_filters_ocurrences_exist?
			# 	@params[:ocurrences]
			# # elsif @init_filters_applyed['in_days']
			# # 	@init_filters_applyed['in_days']
			# else
			@params[:ocurrences] || @opts[:in_days] || []
			# end
		end

		def set_initial_organizers_filter
			@params[:organizers] || @opts[:organizers] || []
		end

		def set_initial_places_filter
			@params[:places] || @opts[:places] || []
		end

		def set_order_by_persona
			if @params.include?(:init_filters_applyed)
				@init_filters_applyed['order_by_persona']
			else
				@params[:order_by_persona] || @opts[:order_by_persona] || false
			end
		end

		def set_not_in_categories
			if @params.include?(:init_filters_applyed)
				@init_filters_applyed['not_in_categories']
			else
				@params[:not_in_categories] || @opts[:not_in_categories] || []
			end
		end

		def set_group_by
			if @params.include?(:init_filters_applyed)
				@init_filters_applyed['group_by']
			else
				@params[:group_by] || @opts[:group_by] || false
			end
		end

		def set_order_by_date
			if @params.include?(:init_filters_applyed)
				@init_filters_applyed['order_by_date']
			else
				@params[:order_by_date] || @opts[:order_by_date] || false
			end
		end

		def set_not_in
			if @params.include?(:init_filters_applyed)
				@init_filters_applyed['not_in']
			else
				@params[:not_in] || @opts[:not_in] || []
			end
		end

		def set_only_in
			if @params.include?(:init_filters_applyed)
				@init_filters_applyed['only_in']
			else
				@params[:only_in] || @opts[:only_in] || []
			end
		end

		def set_high_score
			@params[:with_high_score] || @opts[:with_high_score] || true
		end

		def calculate_items_for_group(number = 2, opts = {})
			# return 15

			if organizers_filter_exist || places_filter_exist
				return nil
			else
				if @params[:limit] && JSON.parse(@params[:limit]) > 8
					return nil
				else
					if opts[:auto_balance] && params_filter_category_exist?
						nil
					elsif opts[:auto_balance] && @opts[:limit]
						(@opts[:limit] / 8) * 2
						# categories = @params.fetch(:categories) || @opts.fetch(:categories)
						# categories.length < 5 ? (8 / categories.length) : 2
					elsif params_filter_kind_exist?
						nil
					else
						number
					end
				end
			end
		end

		def get_filters_from_exist_events(events, type)
			if init_filters_applyed_exist?

				defaults = JSON.parse @params[:defaults]

				case type
				when 'categories'
					defaults[type]
				when 'kinds'
					if params_filter_category_exist?
						events.map { |event| event.kinds_name }.flatten.compact.uniq
					else
						defaults[type]
					end
				when 'ocurrences'
					# if params_filter_category_exist? || params_filter_kind_exist?
					# 	Event.day_of_week(events, active_range: active_range?).sort_by_order.compact_range.uniq.values
					# else
					# if @identifier == 'this-week'
					defaults[type]
					# else
					# 	if @opts[:all_existing_filters]
					# 		Event.day_of_week(CollectionCreator.active_events, active_range: active_range?).sort_by_date.compact_range.uniq.values
					# 	else
					# 		Event.day_of_week(events, active_range: active_range?).sort_by_date.compact_range.uniq.values
					# 	end
					# end
					# end
				end
			else
				case type
				when 'categories'
					# if @opts[:all_existing_filters]
					# 	CollectionCreator.categories
					# else
					events.map { |e| e.categories_primary_name }.flatten.uniq
					# end
				when 'kinds'
					# events.map(&:kinds_name).flatten.uniq
				when 'ocurrences'
					if @opts[:all_existing_filters]
						Event.day_of_week(CollectionCreator.active_events, active_range: active_range?).sort_by_date.compact_range.uniq.values
					else
						Event.day_of_week(events, active_range: active_range?).sort_by_date.compact_range.uniq.values
					end
				end
			end
		end

		def active_range?
			true
		end

		def is_a_activerecord_relation?
			@events.is_a? ActiveRecord::Relation
		end

		def params_filter_category_exist?
			!@params[:categories].blank?
		end

		def params_filter_kind_exist?
			!@params[:kinds].blank?
		end

		def params_filters_ocurrences_exist?
			!@params[:ocurrences].blank?
		end

		def init_filters_applyed_exist?
			!@params[:init_filters_applyed].blank?
		end

		def organizers_filter_exist
			@opts[:organizers].present? || @params[:organizers].present?
		end

		def places_filter_exist
			@opts[:places].present? || @params[:places].present?
		end

		def filters_without_sensitive_info
			filters_cleanned = @dynamic_filters.select { |k, v| k != :user }
			filters_cleanned.store :user, {id: @dynamic_filters[:user][:id]} if @dynamic_filters[:user]
			# filters_cleanned.store :in_user_personas, @dynamic_filters[:user].slice(:id) if @dynamic_filters[:user]
			filters_cleanned.store :all_events_ids, @all_events.map(&:id)
			filters_cleanned.store :current_events_ids, @current_events.map(&:id)
			filters_cleanned
		end
		# TODO: Cache precisa atulizar quando update em eventos
		def cache_variables(current_user)
			case Rails.env
			when 'test'
				CollectionCreator.user          = current_user
				CollectionCreator.active_events = Event.active
				CollectionCreator.kinds         = CollectionCreator.active_events.map { |e| e.kinds.map { |c| c.details['name'] } }.flatten.uniq.freeze
				CollectionCreator.categories    = CollectionCreator.active_events.map { |e| e.categories.map { |c| c.details['name'] } }.flatten.uniq.freeze
			else
				Rails.cache.fetch("collection_creator_#{current_user}") do
					CollectionCreator.user          = current_user
					CollectionCreator.active_events = Event.includes(:place, :categories, :organizers).active
					# CollectionCreator.categories  = CollectionCreator.active_events.map { |e| e.categories.map { |c| c.details['name'] } }.flatten.uniq
					# CollectionCreator.kinds       = CollectionCreator.active_events.map(&:kinds_name).flatten.sort.uniq.freeze
				end
			end
		end
	end
end
