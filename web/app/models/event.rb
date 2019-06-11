class Event < ApplicationRecord

  THEMES = ['lazer', 'saúde', 'atividade física', 'educação', 'cultura', 'alimentação', 'compras', 'cidadania', 'outlier', 'spam'].sort.freeze
  PERSONAS = ['aventureiro', 'cult', 'geek', 'hipster', 'praieiro', 'underground', 'zeen', 'geral', 'outlier'].sort.freeze
  CATEGORIES = ['anúncio', 'festa', 'curso', 'teatro', 'show', 'cinema', 'exposição', 'feira', 'esporte', 'meetup', 'hackaton', 'palestra', 'sarau', 'festival', 'brecho', 'fórum', 'slam', 'protesto', 'outlier'].sort.freeze

  include ImageUploader::Attachment.new(:image)
  include Rails.application.routes.url_helpers
  include EventModel::Dates


  validate :validate_attrs_that_should_be_a_hash
  validate :validate_attrs_that_should_be_a_array

  after_save :reindex, if: proc {|event| event.details_changed?}
  after_destroy :reindex, :destroy_entries

  belongs_to :place
  has_and_belongs_to_many :organizers
  # has_one_attached :cover

  accepts_nested_attributes_for :place, :organizers

  delegate :details_name, to: :place, prefix: true, allow_nil: true

  jsonb_accessor :ocurrences, dates: [:datetime, array: true, default: []]

  searchkick callbacks: false, language: 'portuguese', highlight: %i[name description]

  scope 'for_user', lambda {|user|
    where("(personas -> 'primary' ->> 'name') IN (:primary, :secondary, :tertiary, :quartenary, 'geral') OR
           (personas -> 'secondary' ->> 'name') IN (:primary, :secondary, :tertiary, :quartenary, 'geral')",
          primary: user.personas_primary_name, secondary: user.personas_secondary_name,
          tertiary: user.personas_tertiary_name, quartenary: user.personas_quartenary_name)
  }

  scope 'saved_by_user', lambda {|user|
    where(id: user.taste_events_saved)
  }

  scope 'in_theme', lambda {|themes = [], options = {'not_in': []}|
	  if !options[:not_in].empty?
      where("(theme ->> 'name') NOT IN (?)", options[:not_in])
    else
      where("(theme ->> 'name') IN (?)", themes)
    end
  }

  scope 'with_personas', lambda {|personas|
    if !personas || personas.empty?
      Event.active
    else
      where("(personas -> 'primary' ->> 'name') IN (?)", personas)
    end
  }

  scope 'with_categories', lambda {|categories|
	  if !categories || categories.empty?
      Event.active
    else
      where("(categories -> 'primary' ->> 'name') IN (?)", categories)
    end
  }

  # TODO: Ajustar conflito de filtros específicos e valores de usuários
  scope 'with_kinds', lambda {|kinds|
    kinds = kinds.map{|kind| [{"name": kind}].to_json }
    queries = []
    kinds.each_with_index do |kind, index|
      if index == 0
        queries << "kinds @> '#{kind}'"
      else
        queries << "OR kinds @> '#{kind}'"
      end
    end

    where(ActiveRecord::Base::sanitize_sql queries.join(" "))
  }

  scope 'feed_for_user', lambda {|user, filters = {categories: ['festa', 'curso', 'teatro', 'show', 'cinema', 'exposição', 'feira', 'aventura', 'meetup', 'hackaton', 'palestra', 'celebração', 'workshop', 'oficina', 'aula de dança', 'literatura', 'festival', 'acadêmico', 'gastronômico', 'brecho', 'profissional']}|
    events_for_primary_persona = Event.by_category(filters[:categories], 'primary', 'not_in': ['curso']).by_persona(user.personas_primary_name).active.order_by_score.limit(15)
    events_for_secondary_persona = Event.by_category(filters[:categories], 'secondary', 'not_in': ['curso']).by_persona(user.personas_secondary_name).active.order_by_score.limit(15)
    events_for_tertiary_persona = Event.by_category(filters[:categories], 'tertiary', 'not_in': ['curso']).by_persona(user.personas_tertiary_name).active.order_by_score.limit(15)
    events_for_quartenary_persona = Event.by_category(filters[:categories], 'quartenary', 'not_in': ['curso']).by_persona(user.personas_quartenary_name).active.order_by_score.limit(15)

    count_primary_persona = events_for_primary_persona.count >= 0 ? events_for_primary_persona.count : 0
    count_secondary_persona = events_for_secondary_persona.count + ((5 - count_primary_persona) >= 0 ? (5 - count_primary_persona) : 0)
    count_tertiary_persona = events_for_tertiary_persona.count + (((4 + count_secondary_persona) - count_primary_persona) >= 0 ? (4 + count_secondary_persona) - count_primary_persona : 0)
    count_quartenary_persona = events_for_quartenary_persona.count + (((2 + count_tertiary_persona) - count_secondary_persona) >= 0 ? (2 + count_tertiary_persona) - count_secondary_persona : 0)

    events_for_primary_persona = Event.by_category(filters[:categories], 'primary', 'not_in': ['curso']).by_persona(user.personas_primary_name).active.order_by_score.limit(count_primary_persona)
    events_for_secondary_persona = Event.by_category(filters[:categories], 'secondary', 'not_in': ['curso']).by_persona(user.personas_secondary_name).active.order_by_score.limit(count_secondary_persona)
    events_for_tertiary_persona = Event.by_category(filters[:categories], 'tertiary', 'not_in': ['curso']).by_persona(user.personas_tertiary_name).active.order_by_score.limit(count_tertiary_persona)
    events_for_quartenary_persona = Event.by_category(filters[:categories], 'quartenary', 'not_in': ['curso']).by_persona(user.personas_quartenary_name).active.order_by_score.limit(count_quartenary_persona)

    Event.union(events_for_primary_persona, events_for_secondary_persona, events_for_tertiary_persona, events_for_quartenary_persona).includes(:place).order_by_date.limit(13)
  }

  scope 'order_by_score', lambda {
    order("(personas -> 'primary' ->> 'score')::numeric DESC")
  }

  scope 'in_days', lambda {|ocurrences|
    return all if ocurrences.blank?

    where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) in (?)", ocurrences.map(&:to_date).map(&:yday))
  }

  scope 'order_by_date', lambda {|direction = 'ASC'|
    case direction
    when 'ASC'
      order(Arel.sql "(ocurrences -> 'dates' ->> 0)::timestamptz ASC")
    when 'DESC'
      order(Arel.sql "(ocurrences -> 'dates' ->> 0)::timestamptz DESC")
    end
  }

  scope 'order_by_persona', lambda {|personas = PERSONAS, direction = 'DESC'|

    case direction
    when 'DESC'
      order_by = ["case"]
      personas.each_with_index.map do |persona, index|
        order_by << "WHEN (personas -> 'primary' ->> 'name') = '#{persona}' THEN #{index}"
      end
      order_by << "end"
      order(Arel.sql ActiveRecord::Base::sanitize_sql(order_by.join(" ")))
    when 'ASC'
      order("(personas -> 'primary' ->> 'score')::numeric ASC")
    end
  }

  scope 'by_persona', lambda {|persona, position = 'primary'|
    all
	  # where("((personas -> ? ->> 'name') = ?", position, persona)
  }

  # TODO: Colocar toggle no uso de personas ou não
  scope 'by_category', lambda {|categories, position, opts|
    opts = {'not_in': ['false'], 'group_by': 1, 'active': true, 'turn_on': true, 'personas': PERSONAS}.merge(opts)
    position = position || 'primary'
    categories = categories || CATEGORIES

    return all unless opts[:turn_on]

    if categories.count == 1
	    Event.where("(categories -> :position ->> 'name') NOT IN (:notin) AND (categories -> :position ->> 'name') = :category ", category: categories.first, position: position, notin: opts[:not_in]).active(active).order_by_persona(opts[:personas]).order_by_date.limit(opts[:group_by])
    else
	    queries = []
	    categories.each do |category|
		    queries << Event.where("(categories -> :position ->> 'name') NOT IN (:notin) AND (categories -> :position ->> 'name') = :category ", category: category, position: position, notin: opts[:not_in]).active(active).order_by_persona(opts[:personas]).order_by_date.limit(opts[:group_by])
	    end
	    Event.union(*queries)
    end
  }

  scope 'active', lambda {|turn_on = true|
    if turn_on
      where("(ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now - 1)
    else
      all
    end
  }

  scope 'with_low_score', lambda {|feature|
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

  scope 'favorited_by', lambda {|user = current_user|
    where(id: user.taste_events_saved)
  }

  scope 'by_kind_min_score', lambda {|score|
    Event.select('*').from(Event.select('*, jsonb_array_elements(kinds) as kind')).where("(kind ->> 'score')::numeric >= :score", score: score)
  }

  scope 'by_tag_thing_min_score', lambda {|score|
    Event.select('*').from(Event.select('*, jsonb_array_elements(tags -> things) as tag')).where("(tag ->> 'score')::numeric >= :score", score: score)
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
    adjs = ml_data['adjs']

    nouns.union(verbs, adjs)
  end

  def tags_all
    things = tags['things']
    features = tags['features']
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
    kinds.map {|kind| kind['name']}
  end

  def kinds_scores
    kinds.map {|kind| kind['score']}
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

  def cover_url
    rails_blob_path(cover, disposition: 'attachment', only_path: true) if cover.attached?
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