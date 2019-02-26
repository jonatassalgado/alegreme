class FeedsController < ApplicationController
  def index
    @events = Event.joins(:calendars).order('day_time ASC').distinct
    @favorited_events = Event.where(id: current_user.all_favorited.pluck(:id)).joins(:calendars).order('day_time ASC').distinct if current_user
  end
end
