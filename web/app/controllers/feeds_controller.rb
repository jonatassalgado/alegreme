class FeedsController < ApplicationController
  include EventsService

  before_action :authorize_admin, only: [:train]

  def index
    gon.user_id = current_user.try(:token) || current_or_guest_user.try(:id) || 'null'
    collections ||= EventsService::Collection.new(current_or_guest_user, params)

    if params[:q]
      @items = get_events_for_search_query
    else
      @items = {
          today: collections.events_for_today(group_by: 5, limit: 10),
          cinema: collections.events_for_cinema(group_by: 10),
          show_and_party: collections.events_for_show_and_party(group_by: 5),
          user_personas: collections.events_for_user_personas(group_by: 3, limit: 50)
      }
    end

    @favorited_events = get_favorited_events
  end

  def train
    events_not_trained_yet = get_events_not_trained_yet

    @items = {
        events: events_not_trained_yet.limit(20),
        total_count: events_not_trained_yet.count
    }
  end


  private

  def get_events_not_trained_yet
    Event.where("(theme ->> 'name') IS NULL AND length((details ->> 'description')) > 200")
        .order("(categories -> 'primary' ->> 'score')::numeric  DESC, (personas -> 'primary' ->> 'score')::numeric DESC")
        .includes(:place)
  end

  def get_events_for_search_query
    {
        user: Event.search(params[:q].downcase, highlight: true, limit: 23, includes: [:place])
    }
  end

  def get_favorited_events
    if current_user && !current_user.taste_events_saved.empty?
      Event.saved_by_user(current_user).active.order_by_date.uniq
    else
      []
    end
  end

  protected

  def search_params
    params.permit(:categories, :personas, categories: [], personas: [])
  end
end
