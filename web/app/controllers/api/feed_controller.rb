module Api
    class FeedController < ApplicationController
        def index
            upcoming_events = if params[:day]
                                  Event.includes(:place, :organizers, :categories).valid.in_day(params[:day]).not_ml_data.order_by_date
                              elsif params[:category]
                                  category = Category.find_by("(details ->> 'url') = :category", category: params[:category])
                                  redirect_to root_path, notice: 'Categoria não encontrada' unless category
                                  category.events.includes(:place, :organizers, :categories).not_ml_data.active.valid.order_by_date
                              elsif params[:theme]
                                  theme = Theme.find_by_slug(params[:theme])
                                  Event.includes(:place, :organizers, :categories).active.valid.where(categories: { theme_id: theme.id }).not_ml_data.order_by_date.limit(100)
                              else
                                  Event.includes(:place, :organizers, :categories).active.valid.where(categories: { theme_id: 1 }).not_ml_data.order_by_date.limit(100)
                              end


            @grouped_events = upcoming_events.includes(:categories, :place).limit(100).group_by { |e| e.start_time.strftime("%Y-%m-%d") }
        end
    end
end