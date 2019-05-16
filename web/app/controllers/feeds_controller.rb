class FeedsController < ApplicationController
  before_action :authorize_admin, only: [:train]

  

  def index
  
    if params[:q]
      @events = {
        user: Event.search(params[:q].downcase, highlight: true, limit: 23, include: [:place])
      }
    elsif current_user && current_user.personas_assortment_finished?
      @events = {
        user: Event.feed_for_user(current_user),
        categories: Event.with_categories(params[:categories]).in_days(params[:ocurrences]).active.order_by_date.limit(18).uniq
      }
    elsif params[:personas] || params[:categories] || params[:ocurrences]
      @events = {
        user: Event.with_personas(params[:personas]).with_categories(params[:categories]).in_days(params[:ocurrences]).active.order_by_date.limit(15).uniq
      }      
    else
      @events = {
        user: Event.feed_for_user(current_or_guest_user)
      }
    end
 

    if current_user and !current_user.taste_events_saved.empty?
      @favorited_events = Event.saved_by_user(current_user).active.order_by_date.uniq
    else
      @favorited_events = []
    end
  end


  def train
    @events = {
      underground: Event.by_persona(:underground).not_retrained.limit(20),
      praieiro: Event.by_persona(:praieiro).not_retrained.limit(20),
      cult: Event.by_persona(:cult).not_retrained.limit(20),
      aventureiro: Event.by_persona(:aventureiro).not_retrained.limit(20),
      geek: Event.by_persona(:geek).not_retrained.limit(20),
      hipster: Event.by_persona(:hipster).not_retrained.limit(20),
      turista: Event.by_persona(:turista).not_retrained.limit(20),
      zeen: Event.by_persona(:zeen).not_retrained.limit(20),
      festa: Event.by_category(:festa).not_retrained.limit(20),
      show: Event.by_category(:show).not_retrained.limit(20),
      teatro: Event.by_category(:teatro).not_retrained.limit(20),
      curso: Event.by_category(:curso).not_retrained.limit(20),
      cinema: Event.by_category(:cinema).not_retrained.limit(20),
      exposicao: Event.by_category('exposição').not_retrained.limit(20),
      feira: Event.by_category(:feira).not_retrained.limit(20),
      aventura: Event.by_category(:aventura).not_retrained.limit(20),
    }


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
