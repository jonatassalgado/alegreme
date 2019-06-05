class FeedsController < ApplicationController
  before_action :authorize_admin, only: [:train]

  def index
    gon.user_id = current_user.try(:token) || current_or_guest_user.try(:id) || 'null'
    
    if params[:q]
      @events = {
        user: Event.search(params[:q].downcase, highlight: true, limit: 23, includes: [:place]),
      }
    elsif current_user && current_user.personas_assortment_finished?
      @events = {
        user: Event.feed_for_user(current_user),
        categories: Event.with_categories(params[:categories]).in_days(params[:ocurrences]).active.includes(:place).order_by_date.limit(18).uniq,
      }
    elsif params[:personas] || params[:categories] || params[:ocurrences]
      @events = {
        user: Event.with_personas(params[:personas]).with_categories(params[:categories]).in_days(params[:ocurrences]).active.includes(:place).order_by_date.limit(15).uniq,
      }
    else
      @events = {
        user: Event.feed_for_user(current_or_guest_user),
      }
    end

    if current_user and !current_user.taste_events_saved.empty?
      @favorited_events = Event.saved_by_user(current_user).active.order_by_date.uniq
    else
      @favorited_events = []
    end
  end

  def train
    @events  = Event.all.order("(categories -> 'primary' ->> 'score')::numeric ASC")
                        .order("(personas -> 'primary' ->> 'score')::numeric ASC")
                        .includes(:place)
                        .limit(10)

    if current_user and !current_user.taste_events_saved.empty?
      @favorited_events = Event.where(id: current_user.taste_events_saved).where("ocurrences -> 'dates'->> 0 >= ?", DateTime.now).order("ocurrences -> 'dates' ->> 0 ASC").uniq
    else
      @favorited_events = []
    end
  end

  protected

  def search_params
    params.permit(:categories, :personas, categories: [], personas: [])
  end
end
