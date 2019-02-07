class FeedsController < ApplicationController
  def index
    @events = Event.joins(:calendars).order('day_time ASC')
  end
end
