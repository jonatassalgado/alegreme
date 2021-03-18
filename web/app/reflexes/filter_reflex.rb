# frozen_string_literal: true

class FilterReflex < ApplicationReflex

	def show_filter_group
		if element['data-open'] == 'true'
			morph '#main-sidebar--filter', render(MainSidebar::FilterComponent.new(
				session:           session.id,
				params:            params,
				show_filter_group: nil,
				filters:           Rails.cache.fetch("#{session.id}/main-sidebar--filter/filters", { expires_in: 1.hour, skip_nil: true }) { {} })
			)
		else
			morph '#main-sidebar--filter', render(MainSidebar::FilterComponent.new(
				session:           session.id,
				params:            params,
				show_filter_group: element['data-filter-group'],
				filters:           Rails.cache.fetch("#{session.id}/main-sidebar--filter/filters", { expires_in: 1.hour, skip_nil: true }) { {} })
			)
		end
	end

	def filter

		if Rails.cache.exist?("#{session.id}/main-sidebar--filter/filters")
			@filters = Rails.cache.read("#{session.id}/main-sidebar--filter/filters")
			if element['data-filter-category']
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
				@filters[:date] = element['data-selected'].to_boolean ? nil : element['data-filter-date']
			end
			Rails.cache.write("#{session.id}/main-sidebar--filter/filters", @filters, { expires_in: 1.hour, skip_nil: true })
		else
			@filters[:categories] = [element['data-filter-category']]
			@filters[:date]       = element['data-filter-date']
			Rails.cache.write("#{session.id}/main-sidebar--filter/filters", @filters, { expires_in: 1.hour, skip_nil: true })
		end

		upcoming_events = Event.active.in_day(@filters[:date]).in_categories(@filters[:categories]).not_ml_data.includes(:place).order_by_date.limit(100)

		morph '#main-sidebar--filter', render(MainSidebar::FilterComponent.new(
			session:           session.id,
			show_filter_group: element['data-filter-group'],
			filters:           @filters))

		morph '#main-sidebar--group-by-day-list', render(MainSidebar::GroupByDayListComponent.new(
			events:          upcoming_events,
			user:            current_user,
			open_in_sidebar: true))
	end

	def clear_filter
		upcoming_events = Event.active.in_categories(params[:category] ? params_category : []).not_ml_data.includes(:place).order_by_date.limit(100)

		Rails.cache.delete_matched("#{session.id}/main-sidebar--filter/filters")

		morph '#main-sidebar--filter', render(MainSidebar::FilterComponent.new(
			session:           session.id,
			show_filter_group: nil,
			filters:           { categories: params[:category] ? params_category : [], date: nil }))
		morph '#main-sidebar--group-by-day-list', render(MainSidebar::GroupByDayListComponent.new(
			events:          upcoming_events,
			user:            current_user,
			open_in_sidebar: true))
	end

	private

	def params_category
		[Category::CATEGORIES.select { |hash| hash['url'] == params[:category] }&.first['name']]
	end

end