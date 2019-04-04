class FeedsController < ApplicationController
  def index
    @events = {
      # for_me: Event.joins(:calendars).order('day_time ASC').uniq,
      underground: Event.where("(personas -> 'primary' ->> 'name') = 'underground' AND (personas -> 'primary' ->> 'score')::numeric > 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      praieiro: Event.where("(personas -> 'primary' ->> 'name') = 'praieiro' AND (personas -> 'primary' ->> 'score')::numeric > 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      cult: Event.where("(personas -> 'primary' ->> 'name') = 'cult' AND (personas -> 'primary' ->> 'score')::numeric > 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      aventureiro: Event.where("(personas -> 'primary' ->> 'name') = 'aventureiro' AND (personas -> 'primary' ->> 'score')::numeric > 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      geek: Event.where("(personas -> 'primary' ->> 'name') = 'geek' AND (personas -> 'primary' ->> 'score')::numeric > 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      hipster: Event.where("(personas -> 'primary' ->> 'name') = 'hipster' AND (personas -> 'primary' ->> 'score')::numeric > 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      turista: Event.where("(personas -> 'primary' ->> 'name') = 'turista' AND (personas -> 'primary' ->> 'score')::numeric > 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      zeen: Event.where("(personas -> 'primary' ->> 'name') = 'zeen' AND (personas -> 'primary' ->> 'score')::numeric > 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq
    }


    if current_user and !current_user.all_favorited.empty?
      @favorited_events = Event.where(id: current_user.all_favorited.pluck(:id)).where("ocurrences -> 'dates'->> 0 >= ?", DateTime.now).order("ocurrences -> 'dates' ->> 0 ASC").uniq
    else
      @favorited_events = []
    end
  end
end
