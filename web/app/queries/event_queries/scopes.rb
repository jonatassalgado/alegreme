module EventQueries
	module Scopes
		extend ActiveSupport::Concern

		THEMES     = ['lazer', 'saúde', 'atividade física', 'educação', 'cultura', 'alimentação', 'compras', 'cidadania', 'outlier', 'spam'].sort.freeze
		PERSONAS   = ['aventureiro', 'cult', 'geek', 'hipster', 'praieiro', 'underground', 'zeen', 'geral', 'outlier'].sort.freeze
		CATEGORIES = ['anúncio', 'festa', 'curso', 'teatro', 'show', 'cinema', 'exposição', 'feira', 'esporte', 'meetup', 'hackaton', 'palestra', 'sarau', 'festival', 'brecho', 'fórum', 'slam', 'protesto', 'outlier'].sort.freeze


		included do
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
					where("(ml_data -> 'personas' -> 'primary' ->> 'name') IN (:primary, :secondary, :tertiary, :quartenary, 'geral') OR
           (ml_data -> 'personas' -> 'secondary' ->> 'name') IN (:primary, :secondary, :tertiary, :quartenary, 'geral')",
					      primary:  user.personas_primary_name, secondary: user.personas_secondary_name,
					      tertiary: user.personas_tertiary_name, quartenary: user.personas_quartenary_name)
				else
					all
				end

			}

			scope 'not_in_saved', lambda { |user, opts = {}|
				opts = {'turn_on': true}.merge(opts)
				if opts[:turn_on] && user
					where.not(id: user.taste_events_saved)
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

			scope 'follow_features_by_user', lambda { |user, opts = {}|
				opts = {'turn_on': true}.merge(opts)

				if opts[:turn_on] && user
					user.events_from_following_features
				else
					all
				end

			}

			scope 'saved_by_user', lambda { |user, opts = {}|
				opts = {'turn_on': true}.merge(opts)

				if opts[:turn_on] && user
					where(id: user.taste_events_saved)
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

			scope 'with_categories', lambda { |categories, opts = {}|
				opts = {'turn_on': true}.merge(opts)

				if opts[:turn_on]
					includes(:categories).where("(categories.details ->> 'name') IN (?)", categories).references(:categories)
				else
					all
				end

			}

			scope 'in_kinds', lambda { |kinds, opts = {}|
				opts = {'turn_on': true}.merge(opts)

				if opts[:turn_on] && !kinds.blank?
					kinds   = kinds.map { |kind| [{"name": kind}].to_json }
					queries = []
					kinds.each_with_index do |kind, index|
						if index == 0
							queries << "kinds @> '#{kind}'"
						else
							queries << "OR kinds @> '#{kind}'"
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

			scope 'in_days', lambda { |ocurrences, opts = {}|
				opts = {'turn_on': true}.merge(opts)

				if opts[:turn_on] && !ocurrences.blank?

					ocurrences_to_query = []
					# contains_range = ocurrences.any? { |ocurr| ocurr[0] == '[' }

					# if contains_range
					ocurrences.map do |ocurr|
						is_array = ocurr[0] == '['

						if is_array
							ocurr = JSON.parse ocurr
							ocurrences_to_query << (ocurr[0].to_date..ocurr[1].to_date).to_a.map(&:yday)
						else
							ocurrences_to_query << ocurr.to_date.yday
						end
					end

					where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) IN (?)", ocurrences_to_query.flatten)
				else
					all
				end
			}


			scope 'not_in_days', lambda { |ocurrences, opts = {}|
				opts       = {'turn_on': true}.merge(opts)
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
						order(Arel.sql "(ocurrences -> 'dates' ->> 0)::timestamptz ASC")
					when 'DESC'
						order(Arel.sql "(ocurrences -> 'dates' ->> 0)::timestamptz DESC")
					end
				else
					all
				end

			}

			scope 'order_by_persona', lambda { |active = true, opts = {}|
				opts = {personas: PERSONAS}.merge(opts)
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

				opts   = {'turn_on': true}.merge(opts)
				places = places || []

				if opts[:turn_on] && !places.blank?
					if places.any?(&:numeric?)
						Event.includes(:place).where(places: {id: places})
					else
						Event.includes(:place).where(places: {slug: places})
					end
				else
					all
				end
			}

			scope 'in_categories', lambda { |categories, opts = {}|
				opts       = {'turn_on': true, 'group_by': 5, 'active': true, 'personas': PERSONAS}.merge(opts)
				categories = categories || []

				if opts[:turn_on] && !categories.blank?
					# .where("(categories.details ->> 'name') IN (:categories) ", categories: categories)
					Event.includes(:categories)
							.where("(ml_data -> 'categories' -> 'primary' ->> 'name') IN (:categories) ", categories: categories)
							.references(:categories)
							.active(opts[:active])
							.order_by_persona(true, {personas: opts[:personas]})
							.order_by_date
							.limit(opts[:group_by])

				else
					all
				end
			}


			scope 'in_organizers', lambda { |organizers, opts = {}|
				opts       = {'turn_on': true, 'active': true}.merge(opts)
				organizers = organizers || []

				raise ArgumentError unless organizers.is_a? Array

				if opts[:turn_on] && !organizers.blank?
					id_to_search = organizers.any?(&:numeric?) ? {id: organizers} : {slug: organizers}

					Event.includes(:organizers)
							.where(organizers: id_to_search)
							.references(:organizers)
							.active(opts[:active])
							.order_by_date
				else
					all
				end
			}


			scope 'active', lambda { |turn_on = true|
				if turn_on
					where("(ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now.beginning_of_day)
				else
					all
				end
			}

			scope 'with_low_score', lambda { |feature|
				case feature
				when :personas
					where("(ml_data -> 'personas' -> 'primary' ->> 'score')::numeric < 0.51")
				when :categories
					where("(ml_data -> 'categories' -> 'primary' ->> 'score')::numeric < 0.51")
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