class FavoritesController < ApplicationController
  before_action :authorize_user

  def create
    current_user.taste_events_save favorite_params['event_id'].to_i    

    @locals = {
        identifier: 'salvos',
        event_identifier: "event_#{favorite_params['event_id'].to_i}",
        event_id: favorite_params['event_id'].to_i,
        user: current_user,
        current_event_favorited: true,
        favorited_events: current_user.favorited_events
    }

    respond_to do |format|
      format.js { render 'favorites/favorites' }
    end
  end

  def destroy
    current_user.taste_events_unsave favorite_params['event_id'].to_i

    @locals = {
        identifier: 'salvos',
        event_identifier: "event_#{favorite_params['event_id'].to_i}",
        event_id: favorite_params['event_id'].to_i,
        user: current_user,
        current_event_favorited: false,
        favorited_events: current_user.favorited_events
    }

    respond_to do |format|
      format.js { render 'favorites/favorites' }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def favorite_params
      params.permit(:event_id)
    end
end
