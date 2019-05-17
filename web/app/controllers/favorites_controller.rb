class FavoritesController < ApplicationController
  before_action :authorize_user

  def create
    current_user.taste_events_save favorite_params['event_id'].to_i    

    respond_to do |format|
      format.json { render partial: 'events/favorited_events', locals: {user: current_user, currentEventFavorited: true} }
    end
  end

  def destroy
    current_user.taste_events_unsave favorite_params['event_id'].to_i
    
    respond_to do |format|
      format.json { render partial: 'events/favorited_events', locals: {user: current_user, currentEventFavorited: false} }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def favorite_params
      params.permit(:event_id)
    end
end
