class FavoritesController < ApplicationController


  def create
    @event = Event.find favorite_params['event_id']
    current_user.favorite(@event, scope: [:favorite])
    render json: {
      event_id: @event.id,
      favorited: true,
      all_favorited: Event.where(id: current_user.all_favorited.pluck(:id)).where("ocurrences -> 'dates'->> 0 >= ?", DateTime.now - 1).order("ocurrences -> 'dates' ->> 0 ASC").uniq.as_json({only: [:id, :name], methods: [:cover_url, :day_of_week, :url]})
    }
  end

  def destroy
    @event = Event.find favorite_params['event_id']
    current_user.remove_favorite(@event, scope: ['favorite'])
    render json: {
      event_id: @event.id,
      favorited: false,
      all_favorited: Event.where(id: current_user.all_favorited.pluck(:id)).where("ocurrences -> 'dates'->> 0 >= ?", DateTime.now - 1).order("ocurrences -> 'dates' ->> 0 ASC").uniq.as_json({only: [:id, :name], methods: [:cover_url, :day_of_week, :url]})
    }
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def favorite_params
      params.permit(:event_id)
    end
end
