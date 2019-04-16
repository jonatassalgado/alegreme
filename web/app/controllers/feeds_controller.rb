class FeedsController < ApplicationController
  before_action :authorize_admin, only: [:train]

  def index



    if current_user
      count_primary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (personas -> 'primary' ->> 'score')::numeric >= 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 5)", current_user.personas_primary_name, DateTime.now - 1]).count

      count_secondary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (personas -> 'primary' ->> 'score')::numeric >= 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 4)", current_user.personas_secondary_name, DateTime.now - 1]).count + (5 - count_primary_persona)

      count_tertiary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (personas -> 'primary' ->> 'score')::numeric >= 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 2)", current_user.personas_tertiary_name, DateTime.now - 1]).count + ((4 + count_secondary_persona) - count_primary_persona)

      count_quartenary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (personas -> 'primary' ->> 'score')::numeric >= 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 2)", current_user.personas_quartenary_name, DateTime.now - 1]).count + ((2 + count_tertiary_persona) - count_secondary_persona)

      @events = {
        user: Event.find_by_sql(["
          SELECT events.* FROM
          ((SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND (categories -> 'primary' ->> 'name') NOT IN ('curso') AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') ORDER BY (personas -> 'primary' ->> 'score')::numeric DESC LIMIT ?)
          UNION
          (SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND (categories -> 'primary' ->> 'name') NOT IN ('curso') AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') ORDER BY (personas -> 'primary' ->> 'score')::numeric DESC LIMIT ?)
          UNION
          (SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND (categories -> 'primary' ->> 'name') NOT IN ('curso') AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') ORDER BY (personas -> 'primary' ->> 'score')::numeric DESC LIMIT ?)
          UNION
          (SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND (categories -> 'primary' ->> 'name') NOT IN ('curso') AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') ORDER BY (personas -> 'primary' ->> 'score')::numeric DESC LIMIT ?))
          AS events ORDER BY (ocurrences -> 'dates' ->> 0) ASC  LIMIT 13",
          current_user.personas_primary_name,
          DateTime.now - 1,
          count_primary_persona,
          current_user.personas_secondary_name,
          DateTime.now - 1,
          count_secondary_persona,
          current_user.personas_tertiary_name,
          DateTime.now - 1,
          count_tertiary_persona,
          current_user.personas_quartenary_name,
          DateTime.now - 1,
          count_quartenary_persona]),

          show: Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') IN (?, ?, ?, ?) AND (categories -> 'primary' ->> 'name') = 'show' AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') ORDER BY (personas -> 'primary' ->> 'score')::numeric DESC LIMIT 8)", current_user.personas_primary_name, current_user.personas_secondary_name, current_user.personas_tertiary_name, current_user.personas_quartenary_name, DateTime.now - 1]),

          party: Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') IN (?, ?, ?, ?) AND (categories -> 'primary' ->> 'name') = 'festa' AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') ORDER BY (personas -> 'primary' ->> 'score')::numeric DESC LIMIT 8)", current_user.personas_primary_name, current_user.personas_secondary_name, current_user.personas_tertiary_name, current_user.personas_quartenary_name, DateTime.now - 1])
        }
    else
      @events = {
        user: [],
        show: [],
        party: []
      }
    end




    if current_user and !current_user.taste_events_saved.empty?
      @favorited_events = Event.where(id: current_user.taste_events_saved).where("ocurrences -> 'dates'->> 0 >= ?", (DateTime.now - 1)).order("ocurrences -> 'dates' ->> 0 ASC").uniq
    else
      @favorited_events = []
    end
  end


  def train
    @events = {
      # for_me: Event.joins(:calendars).order('day_time ASC').uniq,
      underground: Event.where("((personas ->> 'outlier') IS NULL OR (personas ->> 'outlier') = 'false') AND (personas -> 'primary' ->> 'name') = 'underground' AND (personas -> 'primary' ->> 'score')::numeric < 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", (DateTime.now - 1)).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      praieiro: Event.where("((personas ->> 'outlier') IS NULL OR (personas ->> 'outlier') = 'false') AND (personas -> 'primary' ->> 'name') = 'praieiro' AND (personas -> 'primary' ->> 'score')::numeric < 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", (DateTime.now - 1)).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      cult: Event.where("((personas ->> 'outlier') IS NULL OR (personas ->> 'outlier') = 'false') AND (personas -> 'primary' ->> 'name') = 'cult' AND (personas -> 'primary' ->> 'score')::numeric < 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", (DateTime.now - 1)).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      aventureiro: Event.where("((personas ->> 'outlier') IS NULL OR (personas ->> 'outlier') = 'false') AND (personas -> 'primary' ->> 'name') = 'aventureiro' AND (personas -> 'primary' ->> 'score')::numeric < 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", (DateTime.now - 1)).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      geek: Event.where("((personas ->> 'outlier') IS NULL OR (personas ->> 'outlier') = 'false') AND (personas -> 'primary' ->> 'name') = 'geek' AND (personas -> 'primary' ->> 'score')::numeric < 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", (DateTime.now - 1)).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      hipster: Event.where("((personas ->> 'outlier') IS NULL OR (personas ->> 'outlier') = 'false') AND (personas -> 'primary' ->> 'name') = 'hipster' AND (personas -> 'primary' ->> 'score')::numeric < 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", (DateTime.now - 1)).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      turista: Event.where("((personas ->> 'outlier') IS NULL OR (personas ->> 'outlier') = 'false') AND (personas -> 'primary' ->> 'name') = 'turista' AND (personas -> 'primary' ->> 'score')::numeric < 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", (DateTime.now - 1)).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq,
      zeen: Event.where("((personas ->> 'outlier') IS NULL OR (personas ->> 'outlier') = 'false') AND (personas -> 'primary' ->> 'name') = 'zeen' AND (personas -> 'primary' ->> 'score')::numeric < 0.51 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?", (DateTime.now - 1)).order(Arel.sql("(ocurrences -> 'dates' ->> 0) ASC")).uniq
    }


    if current_user and !current_user.all_favorited.empty?
      @favorited_events = Event.where(id: current_user.taste_events_saved).where("ocurrences -> 'dates'->> 0 >= ?", DateTime.now).order("ocurrences -> 'dates' ->> 0 ASC").uniq
    else
      @favorited_events = []
    end
  end

end
