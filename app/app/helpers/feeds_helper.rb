module FeedsHelper
  def next_day_to_occur(event)
    if event.calendars.first.day_time?
      distance_of_time_in_words(Time.now, event.calendars.first.day_time)
    end
  end

  def favorited(event)
    unless current_user
      return false
    end
    current_user.favorited?(event, scope: ['favorite'])
  end
end
