class Event < ApplicationRecord

	THEMES     = ['lazer', 'saúde', 'atividade física', 'educação', 'cultura', 'alimentação', 'compras', 'cidadania', 'outlier', 'spam'].sort.freeze
	PERSONAS   = ['aventureiro', 'cult', 'geek', 'hipster', 'praieiro', 'underground', 'zeen', 'geral', 'outlier'].sort.freeze
	CATEGORIES = ['anúncio', 'festa', 'curso', 'teatro', 'show', 'cinema', 'exposição', 'feira', 'esporte', 'meetup', 'hackaton', 'palestra', 'sarau', 'festival', 'brecho', 'fórum', 'slam', 'protesto', 'outlier'].sort.freeze


	include ImageUploader::Attachment.new(:image)
	include Rails.application.routes.url_helpers
	include EventDecorators::Ocurrences


	validate :validate_attrs_that_should_be_a_hash
	validate :validate_attrs_that_should_be_a_array

	after_save :reindex, if: proc { |event| event.details_changed? }
	after_destroy :reindex, :destroy_entries

	belongs_to :place
	has_and_belongs_to_many :organizers

	accepts_nested_attributes_for :place, :organizers

	delegate :details_name, to: :place, prefix: true, allow_nil: true

	searchkick callbacks: false, language: 'portuguese', highlight: %i[name description]

	scope 'for_user', lambda { |user, opts = {}|
		opts = {'turn_on': true}.merge(opts)

		if opts[:turn_on]
			where("(personas -> 'primary' ->> 'name') IN (:primary, :secondary, :tertiary, :quartenary, 'geral') OR
           (personas -> 'secondary' ->> 'name') IN (:primary, :secondary, :tertiary, :quartenary, 'geral')",
			      primary:  user.personas_primary_name, secondary: user.personas_secondary_name,
			      tertiary: user.personas_tertiary_name, quartenary: user.personas_quartenary_name)
		else
			all
		end

	}

	scope 'saved_by_user', lambda { |user, opts = {}|
		opts = {'turn_on': true}.merge(opts)

		if opts[:turn_on]
			where(id: user.taste_events_saved)
		else
			all
		end

	}

	scope 'in_theme', lambda { |themes, opts = {}|
		opts = {'turn_on': true}.merge(opts)

		if opts[:turn_on]
			where("(theme ->> 'name') IN (?)", themes)
		else
			all
		end

	}

	scope 'with_personas', lambda { |personas, opts = {}|
		opts = {'turn_on': true}.merge(opts)

		if opts[:turn_on]
			where("(personas -> 'primary' ->> 'name') IN (?)", personas)
		else
			all
		end

	}

	scope 'with_categories', lambda { |categories, opts = {}|
		opts = {'turn_on': true}.merge(opts)

		if opts[:turn_on]
			where("(categories -> 'primary' ->> 'name') IN (?)", categories)
		else
			all
		end

	}

	# TODO: Ajustar conflito de filtros específicos e valores de usuários
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
			order(Arel.sql"(personas -> 'primary' ->> 'score')::numeric DESC")
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
					is_array            = ocurr[0] == '['

					if is_array
						ocurr = JSON.parse ocurr
						ocurrences_to_query << (ocurr[0].to_date..ocurr[1].to_date).to_a.map(&:yday)
					else
						ocurrences_to_query << ocurr.to_date.yday
					end
				end

				# ocurrences_to_query.flatten


				where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) IN (?)", ocurrences_to_query.flatten)
			# else
			# 	ocurrences_to_query = ocurrences.map(&:to_date).map(&:yday)
			# 	where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) IN (?)", ocurrences_to_query)
			# end

		else
			all
		end
	}


	scope 'not_in_days', lambda { |ocurrences, opts = {}|
		opts       = {'turn_on': true}.merge(opts)
		ocurrences = ocurrences.map(&:to_date).map(&:yday)

		if opts[:turn_on]
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
				order_by << "WHEN (personas -> 'primary' ->> 'name') = '#{persona}' THEN #{index}"
			end
			order_by << "end"
			order(Arel.sql ActiveRecord::Base::sanitize_sql(order_by.join(" "))).order_by_score
		else
			all
		end

	}

	scope 'by_persona', lambda { |persona, position = 'primary'|
		all
		# where("((personas -> ? ->> 'name') = ?", position, persona)
	}

	scope 'in_categories', lambda { |categories, opts = {}|
		opts       = {'turn_on': true, 'group_by': 5, 'active': true, 'personas': PERSONAS}.merge(opts)
		categories = categories || []

		if opts[:turn_on] && !categories.blank?
			if categories.count == 1
				Event.where("(categories -> 'primary' ->> 'name') = :category ", category: categories.first)
						.active(opts[:active])
						.order_by_persona(true, {personas: opts[:personas]})
						.order_by_date
						.limit(opts[:group_by])
			else
				queries = []
				categories.each do |category|
					queries << Event.where("(categories -> 'primary' ->> 'name') = :category ", category: category)
							           .active(opts[:active])
							           .order_by_persona(true, {personas: opts[:personas]})
							           .order_by_date
							           .limit(opts[:group_by])
				end
				Event.union(*queries)
			end
		else
			all
		end


	}

	scope 'active', lambda { |turn_on = true|

		if turn_on
			where("(ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now - 1)
		else
			all
		end
	}

	scope 'with_low_score', lambda { |feature|
		case feature
		when :personas
			where("(personas -> 'primary' ->> 'score')::numeric < 0.51")
		when :categories
			where("(categories -> 'primary' ->> 'score')::numeric < 0.51")
		end
	}

	scope 'not_retrained', lambda {
		where("(categories -> 'primary' ->> 'score')::numeric < 1 OR (personas -> 'primary' ->> 'score')::numeric < 1")
	}

	scope 'favorited_by', lambda { |user = current_user|
		where(id: user.taste_events_saved)
	}

	scope 'by_kind_min_score', lambda { |score|
		Event.select('*').from(Event.select('*, jsonb_array_elements(kinds) as kind')).where("(kind ->> 'score')::numeric >= :score", score: score)
	}


	def details_name
		details['name']
	end

	def details_name=(value)
		details['name'] = value
	end

	def details_description
		details['description']
	end

	def details_description=(value)
		details['description'] = value
	end

	def details_prices
		details['prices']
	end

	def details_prices=(value)
		if value.is_a? Array
			details['prices'] = value
		elsif value.is_a? String
			details['prices'] |= [value]
		else
			raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
		end
	end

	def details_source_url
		details['source_url']
	end

	def details_source_url=(value)
		details['source_url'] = value
	end

	def personas_primary_name
		personas['primary']['name']
	end

	def ml_data_all
		nouns = ml_data['nouns']
		verbs = ml_data['verbs']
		adjs  = ml_data['adjs']

		nouns.union(verbs, adjs)
	end

	def tags_all
		things     = tags['things']
		features   = tags['features']
		activities = tags['activities']

		things&.union(features, activities)
	end

	def tags_of_type(type)
		tags[type] || []
	end

	def tags_things
		tags['things'] || []
	end

	def tags_things_add(value)
		if value.is_a? Array
			tags['things'] = value
		elsif value.is_a? String
			tags['things'] |= [value]
		else
			raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
		end
	end

	def tags_features
		tags['features'] || []
	end

	def tags_features_add(value)
		if value.is_a? Array
			tags['features'] = value
		elsif value.is_a? String
			tags['features'] |= [value]
		else
			raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
		end
	end

	def tags_activities
		tags['activities'] || []
	end

	def tags_activities_add(value)
		if value.is_a? Array
			tags['activities'] = value
		elsif value.is_a? String
			tags['activities'] |= [value]
		else
			raise Exception, "#{value}:#{value.class} -> precisa ser uma string ou array"
		end
	end

	def kinds_name
		kinds.map { |kind| kind['name'] }
	end

	def kinds_scores
		kinds.map { |kind| kind['score'] }
	end

	def theme_name
		theme['name']
	end

	def theme_name=(value)
		theme['name'] = value
	end

	def theme_score
		theme['score']
	end

	def theme_score=(value)
		theme['score'] = value
	end

	def theme_outlier
		theme['outlier']
	end

	def theme_outlier=(value)
		theme['outlier'] = value
	end

	def personas_primary_name=(value)
		personas['primary']['name'] = value
	end

	def personas_secondary_name
		personas['secondary']['name']
	end

	def personas_secondary_name=(value)
		personas['secondary']['name'] = value
	end

	def personas_primary_score
		personas['primary']['score']
	end

	def personas_primary_score=(value)
		personas['primary']['score'] = value
	end

	def personas_secondary_score
		personas['secondary']['score']
	end

	def personas_secondary_score=(value)
		personas['secondary']['score'] = value
	end

	def categories_primary_name
		categories['primary']['name']
	end

	def categories_primary_name=(value)
		categories['primary']['name'] = value
	end

	def categories_secondary_name
		categories['secondary']['name']
	end

	def categories_secondary_name=(value)
		categories['secondary']['name'] = value
	end

	def categories_primary_score
		categories['primary']['score']
	end

	def categories_primary_score=(value)
		categories['primary']['score'] = value
	end

	def categories_secondary_score
		categories['secondary']['score']
	end

	def categories_secondary_score=(value)
		categories['secondary']['score'] = value
	end

	def personas_outlier
		personas['outlier']
	end

	def personas_outlier=(value)
		personas['outlier'] = value
	end

	def categories_outlier
		categories['outlier']
	end

	def categories_outlier=(value)
		categories['outlier'] = value
	end

	def neighborhood
		geographic['neighborhood']
	end

	def neighborhood=(value)
		geographic['neighborhood'] = value
	end

	def cover_url(type = :list)
		image[type].url if image && image[type].exists?
	end

	def url
		event_path(self)
	end

	def first_day_time
		ocurrences['dates'].first
	end


	def datetimes
		datetimes = []

		ocurrences['dates'].each_with_index do |date, _index|
			datetimes << DateTime.parse(date).strftime('%Y-%m-%d %H:%M:%S')
		end

		datetimes
	end

	private

	def destroy_entries
		users = User.where id: saved_by

		users.each do |user|
			user.taste['events']['saved'].delete id
			user.taste['events']['total_saves'] -= 1
		end
	end

	def validate_attrs_that_should_be_a_hash
		['theme', 'personas', 'categories', 'geographic', 'ocurrences', 'details', 'entries', 'ml_data', 'image_data', 'tags'].each do |attr|
			errors.add(attr, 'precisam ser um Hash') unless public_send(attr).is_a? Hash
		end
	end

	def validate_attrs_that_should_be_a_array
		['kinds'].each do |attr|
			errors.add(attr, 'precisam ser um Array') unless public_send(attr).is_a? Array
		end
	end
end