class FavoritesController < ApplicationController


  def create
    @event = Event.find favorite_params['event_id']
    current_user.favorite(@event, scope: [:favorite])
    render json: {
      event_id: @event.id,
      favorited: true,
      all_favorited: Event.where(id: current_user.all_favorited.pluck(:id)).joins(:calendars).order('day_time ASC').uniq.as_json({only: [:id, :name, :day_time], methods: [:cover_url, :url, :day_time, :day_of_week]})
    }
  end

  def destroy
    @event = Event.find favorite_params['event_id']
    current_user.remove_favorite(@event, scope: ['favorite'])
    render json: {
      event_id: @event.id,
      favorited: false,
      all_favorited: Event.where(id: current_user.all_favorited.pluck(:id)).joins(:calendars).order('day_time ASC').uniq.as_json({only: [:id, :name, :day_time], methods: [:cover_url, :url, :day_time, :day_of_week]})
    }
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def favorite_params
      params.permit(:event_id)
    end
end
