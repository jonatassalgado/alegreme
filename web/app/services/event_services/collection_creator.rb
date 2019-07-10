# noinspection ALL
module EventServices
	class CollectionCreator
		class << self
			attr_accessor :user, :active_events, :categories, :kinds, :default_filters
		end

		def initialize(current_user, request_params = {})
			cache_variables(current_user)

			@params   = request_params || {}
			@today    = Date.current
			@tomorrow = @today + 1
		end

		def call(collection, opts = {})
			return {} if collection.blank?

			if collection.is_a?(Hash) && collection.key?(:identifier)
				@collection = collection[:collection]
				@identifier = collection[:identifier]
			else
				@identifier = collection
				@collection = Event.all
			end

			@opts            = default_options(opts)
			@dynamic_filters = default_filters.merge(get_filters_for_collection)
			@events          = EventFetcher.new(@collection, @dynamic_filters).call
				                 # else
					               #   EventFetcher.new(Event.all, @dynamic_filters).call
			                   # end

			mount_response
		end


		private

		def default_filters
			{
					in_categories:    set_initial_categories_filter,
					in_days:          set_initial_dates_filter,
					in_kinds:         set_initial_kinds_filter,
					order_by_date:    false,
					order_by_persona: false,
					group_by:         calculate_items_for_group(2, auto_balance: true),
					not_in:           set_not_in,
					limit:            set_limit
			}
		end

		def get_filters_for_collection
			collections = {
					'today-and-tomorrow' => {
							in_days:          [@today.to_s, @tomorrow.to_s],
							in_user_personas: get_current_user,
							order_by_persona: true
					},
					'user-personas'      => {
							in_user_personas: CollectionCreator.user,
							in_days:          set_initial_dates_filter,
							order_by_persona: true
					},
					'follow'             => {
							in_days:            set_initial_dates_filter,
							order_by_persona:   true,
							in_follow_features: true,
							group_by:           calculate_items_for_group(5, auto_balance: true)
					},
					'user-suggestions'   => {
							in_user_suggestions: CollectionCreator.user,
							in_days:             set_initial_dates_filter,
							order_by_persona:    false
					},
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
							all_existing_filters: false
					},
					'user-personas'      => {
							all_existing_filters: false
					},
					'follow'             => {
							all_existing_filters: false
					},
					'user-suggestions'   => {
							all_existing_filters: false
					}
			}

			if default_opts.key?(@identifier)
				default_opts[@identifier].merge(opts)
			else
				{all_existing_filters: false}.merge(opts)
			end
		end

		def get_filters_toggle_for_collection
			filters = {
					'today-and-tomorrow' => {
							categories: true,
							kinds:      true
					},
					'user-personas'      => {
							categories: true,
							kinds:      true,
							ocurrences: true
					},
					'follow'             => {
							categories: true,
							kinds:      true,
							ocurrences: true
					},
					'user-suggestions'   => {
							categories: true,
							kinds:      true,
							ocurrences: true
					}
			}

			filters[@identifier] || {
					categories: false,
					kinds:      false,
					ocurrences: false
			}
		end

		def get_current_user
			CollectionCreator.user
		end

		def set_limit
			@params[:limit] || @opts[:limit] || 8
		end

		def group_by_or_kinds_not_exist?(opts)
			@params[:categories] || (!opts[:group_by].blank? || @params[:kinds].blank?)
		end

		def mount_response
			{
					events:     @events,
					categories: get_filters_from_exist_events(@events, 'categories'),
					kinds:      get_filters_from_exist_events(@events, 'kinds'),
					ocurrences: get_filters_from_exist_events(@events, 'ocurrences'),
					filters:    get_filters_toggle_for_collection,
					detail:     {
							events_in_collection: @events.size,
							init_filters_applyed: filters_without_sensitive_info
					}
			}
		end

		def set_initial_categories_filter
			@params[:categories] || @opts[:categories] || []
		end

		def set_initial_kinds_filter
			@params[:kinds] || @opts[:kinds] || []
		end

		def set_initial_dates_filter
			@params[:ocurrences] || @opts[:ocurrences] || []
		end

		def set_not_in
			if @params.include?(:init_filters_applyed)
				init_filters_applyed = JSON.parse(@params[:init_filters_applyed])
				init_filters_applyed['not_in']
			else
				@opts[:not_in] || []
			end
		end

		def calculate_items_for_group(number = 2, opts = {})
			if opts[:auto_balance] && @opts[:limit]
				(@opts[:limit] / 8) * 2
			elsif opts[:auto_balance] && params_filter_category_exist?
				categories = @params.fetch(:categories) || CollectionCreator.categories
				categories.count < 5 ? (8 / categories.count) : 2
			elsif params_filter_kind_exist?
				8
			elsif number
				number
			else
				2
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
						events.map { |e| e.kinds.map { |c| c.details['name'] } }.flatten.uniq
					else
						defaults[type]
					end
				when 'ocurrences'
					if params_filter_category_exist? || params_filter_kind_exist?
						Event.day_of_week(events, active_range: active_range?).sort_by_order.compact_range.uniq.values
					else
						defaults[type]
					end
				end
			else
				case type
				when 'categories'
					if @opts[:all_existing_filters]
						CollectionCreator.categories
					else
						events.map { |e| e.categories.map { |c| c.details['name'] } }.flatten.uniq
					end
				when 'kinds'
					# events.map(&:kinds_name).flatten.uniq
				when 'ocurrences'
					if @opts[:all_existing_filters]
						Event.day_of_week(CollectionCreator.active_events, active_range: active_range?).sort_by_order.compact_range.uniq.values
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
			@collection.is_a? ActiveRecord::Relation
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

		def filters_without_sensitive_info
			filters_cleanned = @dynamic_filters
			filters_cleanned.store :in_user_personas, @dynamic_filters[:in_user_personas].slice(:id) if @dynamic_filters[:in_user_personas]
			filters_cleanned.store :events_ids, @events.map(&:id)
			filters_cleanned
		end

		def cache_variables(current_user)
			case Rails.env
			when 'test'
				CollectionCreator.user          = current_user
				CollectionCreator.active_events = Event.active
				CollectionCreator.kinds         = CollectionCreator.active_events.map { |e| e.kinds.map { |c| c.details['name'] } }.flatten.uniq.freeze
				CollectionCreator.categories    = CollectionCreator.active_events.map { |e| e.categories.map { |c| c.details['name'] } }.flatten.uniq.freeze
			else
				CollectionCreator.user          = current_user
				CollectionCreator.active_events ||= Event.includes(:place, :categories, :organizers).active
				# CollectionCreator.kinds         ||= CollectionCreator.active_events.map(&:kinds_name).flatten.sort.uniq.freeze
				CollectionCreator.categories ||= CollectionCreator.active_events.map { |e| e.categories.map { |c| c.details['name'] } }.flatten.uniq
			end
		end
	end
end
