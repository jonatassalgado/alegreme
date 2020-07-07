module EventQueries
  module Scopes
    extend ActiveSupport::Concern

    included do

      scope 'in_neighborhoods', lambda { |neighborhoods, opts = {}|
        opts = {'turn_on': true}.merge(opts)

        return Event.none unless neighborhoods
        if opts[:turn_on]
          where("(events.geographic ->> 'neighborhood') IN (:neighborhoods)", neighborhoods: neighborhoods)
        else
          all
        end
      }

      scope 'from_followed_users', lambda { |follower|
        return Event.none unless follower
        where("? @> ANY (ARRAY(select jsonb_array_elements(entries -> 'saved_by')))", follower.following['users'].to_json)
      }

      scope 'in_user_suggestions', lambda { |user, opts = {}|
        opts = {'turn_on': true}.merge(opts)

        if opts[:turn_on] && user
          where(id: user.suggestions['events'])
        else
          all
        end
      }

      scope 'in_user_personas', lambda { |user, opts = {}|
        opts = {'turn_on': true}.merge(opts)
        if opts[:turn_on] && user
          where("(ml_data -> 'personas' -> 'primary' ->> 'name') IN (:primary, :secondary, :tertiary, :quartenary) OR
                (ml_data -> 'personas' -> 'secondary' ->> 'name') IN (:primary, :secondary, :tertiary, :quartenary)",
                primary: user.personas_primary_name, secondary: user.personas_secondary_name,
                tertiary: user.personas_tertiary_name, quartenary: user.personas_quartenary_name)
        else
          all
        end

      }

      scope 'not_in_disliked', lambda { |user, opts = {}|
        opts = {'turn_on': true}.merge(opts)
        if opts[:turn_on] && user
          where.not(id: user.taste_events_disliked)
        else
          all
        end
      }

      scope 'not_in', lambda { |ids, opts = {}|
        opts = {'turn_on': true}.merge(opts)
        if opts[:turn_on] && !ids.blank?
          where.not(id: ids)
        else
          all
        end
      }

      scope 'only_in', lambda { |ids, opts = {}|
        opts = {'turn_on': true}.merge(opts)
        if opts[:turn_on] && !ids.blank?
          where(id: ids)
        else
          all
        end
      }

      scope 'following_topics_by_user', lambda { |user, opts = {}|
        opts = {'turn_on': true}.merge(opts)

        if opts[:turn_on] && user
          user.events_from_following_topics
        else
          all
        end

      }

      scope 'in_theme', lambda { |themes, opts = {}|
        opts = {'turn_on': true}.merge(opts)

        if opts[:turn_on] && !themes.blank?
          where("(theme ->> 'name') IN (?)", themes)
        else
          all
        end

      }

      scope 'with_personas', lambda { |personas, opts = {}|
        opts = {'turn_on': true}.merge(opts)

        if opts[:turn_on]
          where("(ml_data -> 'personas' -> 'primary' ->> 'name') IN (?)", personas)
        else
          all
        end

      }

      # scope 'with_categories', lambda { |categories, opts = {}|
      # opts = {'turn_on': true}.merge(opts)
      #
      # if opts[:turn_on]
      # 	includes(:categories).where("(categories.details ->> 'name') IN (?)", categories).references(:categories)
      # else
      # all
      # end
      # }

      scope 'in_kinds', lambda { |kinds, opts = {}|
        opts = {'turn_on': true}.merge(opts)

        if opts[:turn_on] && !kinds.blank?
          kinds = kinds.map { |kind| [{"name": kind}].to_json }
          queries = []
          kinds.each_with_index do |kind, index|
            if index == 0
              queries << "ml_data -> 'kinds' @> '#{kind}'"
            else
              queries << "OR ml_data -> 'kinds' @> '#{kind}'"
            end
          end
          where(ActiveRecord::Base::sanitize_sql queries.join(" "))
        else
          all
        end

      }

      scope 'order_by_score', lambda { |opts = {}|
        opts = {'turn_on': true}.merge(opts)

        if opts[:turn_on]
          order(Arel.sql "(ml_data -> 'personas' -> 'primary' ->> 'score')::numeric DESC")
        else
          all
        end
      }

      scope 'in_next_2_hours', lambda {
        where("(ocurrences -> 'dates' ->> 0)::timestamptz BETWEEN ? AND ?", DateTime.now - 2.hours, DateTime.now)
      }

      scope 'in_days', lambda { |ocurrences, opts = {}|
        opts = {'turn_on': true}.merge(opts)

        if opts[:turn_on] && ocurrences.present?

          # ocurrences_to_query = []
          # contains_range = ocurrences.any? { |ocurr| ocurr[0] == '[' }

          # if contains_range
          # ocurrences.map do |ocurr|
            # ocurrences_to_query << ocurrences.map(&:yday)
            # is_array = ocurr[0] == '['

            # if ocurr
            #   ocurr = JSON.parse ocurr
            #   ocurrences_to_query << (ocurr[0].to_date..ocurr[1].to_date).to_a.map(&:yday)
            # else
            #   ocurrences_to_query << ocurr.to_date.yday
            # end
          # end

          where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) IN (?)", ocurrences)
        else
          all
        end
      }


      scope 'not_in_days', lambda { |ocurrences, opts = {}|
        opts = {'turn_on': true}.merge(opts)
        ocurrences = ocurrences.map(&:to_date).map(&:yday)

        if opts[:turn_on] && !ocurrences.blank?
          where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) NOT IN (?)", ocurrences)
        else
          all
        end
      }

      scope 'order_by_date', lambda { |active = true, opts = {}|
        opts = {'direction': 'ASC'}.merge(opts)

        if active
          case opts[:direction]
          when 'ASC'
            order("(ocurrences -> 'dates' ->> 0)::timestamptz ASC").order_by_score
          when 'DESC'
            order("(ocurrences -> 'dates' ->> 0)::timestamptz DESC").order_by_score
          end
        else
          all
        end
      }


      scope 'order_by_ids', lambda { |ids = false|
        if ids.is_a?(Array)
          order("position(id::text in '#{ids.join(',')}')")
        else
          all
        end
      }


      scope 'order_by_persona', lambda { |active = true, opts = {}|
        opts = {personas: Event::PERSONAS}.merge(opts)
        if active && !opts[:personas].blank?
          order_by = ["case"]
          opts[:personas].each_with_index.map do |persona, index|
            order_by << "WHEN (ml_data -> 'personas' -> 'primary' ->> 'name') = '#{persona}' THEN #{index}"
          end
          order_by << "end"
          order(Arel.sql ActiveRecord::Base::sanitize_sql(order_by.join(" "))).order_by_score
        else
          all
        end

      }

      scope 'by_persona', lambda { |persona, position = 'primary'|
        all
        # where("((ml_data -> 'personas' -> ? ->> 'name') = ?", position, persona)
      }

      scope 'in_places', lambda { |places, opts = {}|
        raise ArgumentError unless places.is_a? Array

        opts = {'turn_on': true}.merge(opts)
        places = places || []

        if opts[:turn_on] && !places.blank?
          if places.any?(&:numeric?)
            joins(:place)
                .where("places.id IN (?)", places)
            # where("places.id IN (?)", places)
            # select("e.*").from("events AS e").joins("INNER JOIN places p ON e.place_id = p.id").where("p.id IN (?)", places)
          else
            joins(:place)
                .where("places.slug IN (?)", places)
            # where("places.slug IN (?)", places)
            # select("e.*").from("events AS e").joins("INNER JOIN places p ON e.place_id = p.id").where("p.slug IN (?)", places)
          end
        else
          all
        end
      }

      scope 'in_categories', lambda { |categories, opts = {}|
        opts = {'turn_on': true, 'group_by': nil, 'active': true, 'personas': Event::PERSONAS, 'not_in': []}.merge(opts)
        categories = categories.present? ? (categories - opts[:not_in]) : (Event::CATEGORIES - opts[:not_in])

        if opts[:group_by] && categories.present?
          raise ArgumentError, "categorias precisa ser um array" unless categories.is_a? Array
          raise ArgumentError, "group_by precisa ser numérico" unless opts[:group_by].is_a? Numeric

          categories_query_array = categories.map{|category| "'#{category}'"}.join(', ')

          from(
              <<~SQL
                (SELECT events.* from (
                    SELECT *,
                       (p.ml_data -> 'categories' -> 'primary' ->> 'score')::numeric AS score,
                       row_number()  OVER (
                           PARTITION BY p.ml_data -> 'categories' -> 'primary' -> 'name'
                           ORDER BY (p.ml_data -> 'categories' -> 'primary' ->> 'score')::numeric DESC
                           ) AS rank
                    FROM events AS p
                    ) AS events
                WHERE events.score IS NOT NULL
                  AND rank::numeric <= #{ActiveRecord::Base::sanitize_sql(opts[:group_by])}
                  AND (events.ml_data -> 'categories' -> 'primary' ->> 'name') IN (#{ActiveRecord::Base::sanitize_sql(categories_query_array)})
                ORDER BY events.rank) events
          SQL
          )
        elsif opts[:group_by].blank?
          where("(ml_data -> 'categories' -> 'primary' ->> 'name') IN (:categories)", categories: categories)
        else
          all
        end
      }


      scope 'in_organizers', lambda { |organizers, opts = {}|
        opts = {'turn_on': true, 'active': true}.merge(opts)
        organizers = organizers || []

        raise ArgumentError unless organizers.is_a? Array

        if opts[:turn_on] && !organizers.blank?
          if organizers.any?(&:numeric?)
            joins(:organizers)
                .where("organizers.id IN (?)", organizers)
          else
            joins(:organizers)
                .where("organizers.slug IN (?)", organizers)
          end
        else
          all
        end
      }


      scope 'active', lambda { |turn_on = true|
        if turn_on
          where("(ocurrences -> 'dates' ->> 0)::timestamptz > ? AND (ml_data -> 'categories' -> 'primary' ->> 'name') != 'outlier'", (DateTime.now - 6.hours))
        else
          all
        end
      }

      scope 'with_low_score', lambda {
        where("(ml_data -> 'personas' -> 'primary' ->> 'score')::numeric < 0.7 AND (ml_data -> 'categories' -> 'primary' ->> 'score')::numeric < 0.7")
      }

      scope 'with_high_score', lambda { |opts = {}|
        opts = {'turn_on': true, 'active': true}.merge(opts)

        if opts[:turn_on]
          persona_score = 0.35
          category_score = 0.7
          where("(ml_data -> 'personas' -> 'primary' ->> 'score')::numeric >= :persona_score AND (ml_data -> 'categories' -> 'primary' ->> 'score')::numeric >= :category_score", persona_score: persona_score, category_score: category_score)
        else
          all
        end
      }

      scope 'not_retrained', lambda {
        where("(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric < 1 OR (ml_data -> 'personas' -> 'primary' ->> 'score')::numeric < 1")
      }

      scope 'favorited_by', lambda { |user = current_user|
        where(id: user.taste_events_saved)
      }

      scope 'by_kind_min_score', lambda { |score|
        Event.select('*').from(Event.select('*, jsonb_array_elements(kinds) as kind')).where("(kind ->> 'score')::numeric >= :score", score: score)
      }
    end


  end
end
