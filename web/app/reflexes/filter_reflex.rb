# frozen_string_literal: true

class FilterReflex < ApplicationReflex

	def show_filter_group
		show_filter_group = element['data-open'] == 'true' ? nil : element['data-filter-group']

		morph '#main-sidebar--filter', render(MainSidebar::FilterComponent.new(
			session:           session.id,
			open:              true,
			params:            params,
			show_filter_group: show_filter_group,
			filters:           Rails.cache.fetch("#{session.id}/main-sidebar--filter/filters", { expires_in: 1.hour, skip_nil: true }) { {} })
		)
	end

	def filter
		if Rails.cache.exist?("#{session.id}/main-sidebar--filter/filters")
			@filters = Rails.cache.read("#{session.id}/main-sidebar--filter/filters")
			if element['data-filter-theme']
				@filters[:theme] = element['data-filter-theme']
			end
			if element['data-filter-category']
				@filters[:theme] = nil
				if element['data-selected'].to_boolean
					@filters[:categories].delete(element['data-filter-category'])
				else
					if @filters[:categories].size == 2
						@filters[:categories].delete_at(0)
						@filters[:categories] |= [element['data-filter-category']]
					else
						@filters[:categories] |= [element['data-filter-category']]
					end
				end
			end
			if element['data-filter-date']
				@filters[:theme] = nil
				@filters[:date]  = element['data-selected'].to_boolean ? nil : element['data-filter-date']
			end
		else
			@filters              = {}
			@filters[:theme]      = element['data-filter-theme']
			@filters[:categories] = [element['data-filter-category']]
			@filters[:date]       = element['data-filter-date']
		end

		Rails.cache.write("#{session.id}/main-sidebar--filter/filters", @filters, { expires_in: 1.hour, skip_nil: true })

		pagy, upcoming_events = pagy(requested_resources, { page: 1 })

		morph '#main-sidebar--filter', render(MainSidebar::FilterComponent.new(
			session:           session.id,
			open:              element['data-filter-category'].present?,
			show_filter_group: element['data-filter-group'],
			filters:           @filters))

		morph '#main-sidebar--group-by-day-list', render(MainSidebar::GroupByDayListComponent.new(
			events:          upcoming_events,
			user:            current_user,
			pagy:            pagy,
			filters:         @filters,
			open_in_sidebar: true))
	end

	def clear_filter
		if element['data-filter-only'] == 'category'
			filters              = Rails.cache.read("#{session.id}/main-sidebar--filter/filters")
			filters[:theme]      = 'entretenimento-lazer'
			filters[:categories] = []
			Rails.cache.write("#{session.id}/main-sidebar--filter/filters", filters, { expires_in: 1.hour, skip_nil: true })

			pagy, upcoming_events = pagy(Event.includes(:place, :organizers, :categories).active.valid.where(categories: { theme_id: 1 }).in_day(filters[:date]).order_by_date.limit(100), { page: 1 })

			morph '#main-sidebar--filter', render(MainSidebar::FilterComponent.new(
				session: session.id,
				open:    false,
				filters: filters))

			morph '#main-sidebar--group-by-day-list', render(MainSidebar::GroupByDayListComponent.new(
				events:          upcoming_events,
				user:            current_user,
				pagy:            pagy,
				filters:         filters,
				open_in_sidebar: true))
		else
			pagy, upcoming_events = pagy(Event.includes(:place, :organizers, :categories).active.valid.where(categories: { theme_id: 1 }).in_categories(params[:category] ? params_category : []).order_by_date.limit(100), { page: 1 })

			Rails.cache.delete_matched("#{session.id}/main-sidebar--filter/filters")

			morph '#main-sidebar--filter', render(MainSidebar::FilterComponent.new(
				session:           session.id,
				show_filter_group: nil,
				filters:           clean_filters))
			morph '#main-sidebar--group-by-day-list', render(MainSidebar::GroupByDayListComponent.new(
				events:          upcoming_events,
				pagy:            pagy,
				filters:         clean_filters,
				user:            current_user,
				open_in_sidebar: true))
		end
	end

	def open
		show_filter_group = element['data-filter-group'].blank? ? 'category' : element['data-filter-group']

		morph '#main-sidebar--filter', render(MainSidebar::FilterComponent.new(
			session:           session.id,
			open:              true,
			show_filter_group: show_filter_group,
			filters:           clean_filters))
	end

	def close
		morph '#main-sidebar--filter', render(MainSidebar::FilterComponent.new(
			session:           session.id,
			open:              false,
			show_filter_group: element['data-filter-group'],
			filters:           clean_filters))
	end

	private

	def requested_resources
		if !@filters[:theme] && (@filters[:categories] || @filters[:date])
			Event.includes(:place, :organizers, :categories).active.valid.in_day(@filters[:date]).in_categories(@filters[:categories]).order_by_date.limit(100)
		else
			@theme = Theme.find_by_slug(@filters[:theme])
			Event.includes(:place, :organizers, :categories, :events_organizers, :categories_events).active.valid.where(categories: { theme_id: @theme.id }).order_by_date.limit(100)
		end
	end

	def clean_filters
		{ theme: 'entretenimento-lazer', categories: params[:category] ? params_category : [], date: nil }
	end

	def params_category
		[Category::CATEGORIES.select { |hash| hash['url'] == params[:category] }&.first['name']]
	end

end