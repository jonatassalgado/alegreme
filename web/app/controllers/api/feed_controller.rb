module Api
	class FeedController < ApplicationController
		def index
			@user           = current_user
			upcoming_events = if params[:day]
													Event.includes(:place, :categories).valid.in_day(params[:day]).order_by_date
												elsif params[:category]
													category = Category.find_by("(details ->> 'url') = :category", category: params[:category])
													redirect_to root_path, notice: 'Categoria não encontrada' unless category
													category.events.includes(:place, :categories).active.valid.order_by_date
												elsif params[:theme]
													theme = Theme.find_by_slug(params[:theme])
													Event.includes(:place, :categories).active.valid.where(categories: { theme_id: theme.id }).order_by_date.limit(100)
												else
													Event.includes(:place, :categories).active.valid.where(categories: { theme_id: 1 }).order_by_date.limit(100)
												end

			@grouped_events = upcoming_events.includes(:categories, :place, :categories_events).limit(200).group_by { |e| e.start_time.to_date }
		end
	end
end