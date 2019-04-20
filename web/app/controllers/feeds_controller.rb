class FeedsController < ApplicationController
  before_action :authorize_admin, only: [:train]



  def index
    if current_user
      count_primary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (personas -> 'primary' ->> 'score')::numeric >= 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 5)", current_user.personas_primary_name, DateTime.now - 1]).count
      count_secondary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (personas -> 'primary' ->> 'score')::numeric >= 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 4)", current_user.personas_secondary_name, DateTime.now - 1]).count + (5 - count_primary_persona)
      count_tertiary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (personas -> 'primary' ->> 'score')::numeric >= 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 2)", current_user.personas_tertiary_name, DateTime.now - 1]).count + ((4 + count_secondary_persona) - count_primary_persona)
      count_quartenary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (personas -> 'primary' ->> 'score')::numeric >= 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 2)", current_user.personas_quartenary_name, DateTime.now - 1]).count + ((2 + count_tertiary_persona) - count_secondary_persona)

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
          AS events ORDER BY (ocurrences -> 'dates' ->> 0) ASC  LIMIT 15",
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

          show: Event.by_category(:show),

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
    params.permit(:categories, categories: [])
  end

end
