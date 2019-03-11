class FeedsController < ApplicationController
  def index
    @events = {
      # for_me: Event.joins(:calendars).order('day_time ASC').uniq,
      underground: Event.where("(features -> 'persona' -> 'primary' ->> 'name') = 'underground' AND (features -> 'persona' -> 'primary' ->> 'score')::numeric > 0.35").joins(:calendars).where('day_time >= ?', DateTime.now),
      praieiro: Event.where("(features -> 'persona' -> 'primary' ->> 'name') = 'praieiro' AND (features -> 'persona' -> 'primary' ->> 'score')::numeric > 0.35").joins(:calendars).where('day_time >= ?', DateTime.now),
      cult: Event.where("(features -> 'persona' -> 'primary' ->> 'name') = 'cult' AND (features -> 'persona' -> 'primary' ->> 'score')::numeric > 0.35").joins(:calendars).where('day_time >= ?', DateTime.now),
      aventureiro: Event.where("(features -> 'persona' -> 'primary' ->> 'name') = 'aventureiro' AND (features -> 'persona' -> 'primary' ->> 'score')::numeric > 0.35").joins(:calendars).where('day_time >= ?', DateTime.now),
      geek: Event.where("(features -> 'persona' -> 'primary' ->> 'name') = 'geek' AND (features -> 'persona' -> 'primary' ->> 'score')::numeric > 0.35").joins(:calendars).where('day_time >= ?', DateTime.now),
      hipster: Event.where("(features -> 'persona' -> 'primary' ->> 'name') = 'hipster' AND (features -> 'persona' -> 'primary' ->> 'score')::numeric > 0.35").joins(:calendars).where('day_time >= ?', DateTime.now),
      turista: Event.where("(features -> 'persona' -> 'primary' ->> 'name') = 'turista' AND (features -> 'persona' -> 'primary' ->> 'score')::numeric > 0.35").joins(:calendars).where('day_time >= ?', DateTime.now),
      zeen: Event.where("(features -> 'persona' -> 'primary' ->> 'name') = 'zeen' AND (features -> 'persona' -> 'primary' ->> 'score')::numeric > 0.35").joins(:calendars).where('day_time >= ?', DateTime.now)
    }


    @favorited_events = Event.where(id: current_user.all_favorited.pluck(:id)).joins(:calendars).where('day_time >= ?', DateTime.now).order('day_time ASC').uniq if current_user
  end
end
