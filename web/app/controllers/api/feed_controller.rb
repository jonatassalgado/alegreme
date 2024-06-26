module Api
	class FeedController < ApplicationController
		def index
			@user           = current_user
			upcoming_events = if params[:day]
													Event.includes(:place, :categories, :categories_events).valid.in_day(params[:day]).order_by_date
												elsif params[:category]
													categories_group = CategoriesGroup.find_by("url = :category", category: params[:category])

													if categories_group
														categories_group.events.includes(:place, :categories, :categories_events).active.valid.order_by_date
													else
														category = Category.find_by("(details ->> 'url') = :category", category: params[:category])
														redirect_to root_path, notice: 'Categoria não encontrada' unless category
														category.events.includes(:place, :categories, :categories_events).active.valid.order_by_date
													end
												elsif params[:theme]
													theme = Theme.find_by_slug(params[:theme])
													Event.includes(:place, :categories, :categories_events).active.valid.where(categories: { theme_id: theme.id }).order_by_date.limit(100)
												else
													Event.includes(:place, :categories, :categories_events).active.valid.where(categories: { theme_id: 1 }).order_by_date.limit(100)
												end

			@pagy, events   = pagy(upcoming_events, page: params.fetch(:page, 1))
			@grouped_events = events.group_by { |e| e.start_time.to_date }
		end
	end
end