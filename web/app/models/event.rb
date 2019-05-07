class Event < ApplicationRecord
  require "day_of_week"
  
  include Rails.application.routes.url_helpers

  after_save :reindex, if: proc{ |event| event.description_changed? }
  after_destroy :reindex, :destroy_entries
  
  belongs_to :place
  has_and_belongs_to_many :organizers
  has_one_attached :cover
  
  accepts_nested_attributes_for :place, :organizers
  
  delegate :name, :address, to: :place, prefix: true, allow_nil: true
  
  jsonb_accessor :ocurrences, dates: [:datetime, array: true, default: []]
  
  searchkick callbacks: false, language: "portuguese", highlight: [:name, :description]

  # scope :with_eager_loaded_cover, -> { eager_load(cover_attachment: :blob) }
  # scope :with_preloaded_cover, -> { preload(cover_attachment: :blob) }

  scope 'for_user', -> (user) {
    where("(personas -> 'primary' ->> 'name') IN (?, ?, ?, ?)", user.personas_primary_name, user.personas_secondary_name, user.personas_tertiary_name, user.personas_quartenary_name)
  }

  scope 'saved_by_user', -> (user) {
    where(id: user.taste_events_saved)
  }

  scope 'with_personas', -> (personas) {
    if !personas || personas.empty?
      Event.active
    else
      where("(personas -> 'primary' ->> 'name') IN (?)", personas)
    end
  }

  scope 'with_categories', -> (categories) {
    if !categories || categories.empty?
      Event.active
    else
      where("(categories -> 'primary' ->> 'name') IN (?)", categories)
    end
  }

  scope 'feed_for_user', -> (user, filters = {categories: ["festa", "curso", "teatro", "show", "cinema", "exposição", "feira", "aventura", "meetup", "hackaton", "palestra", "celebração", "workshop", "oficina", "aula de dança", "literatura", "festival", "acadêmico", "gastronômico", "brecho", "profissional"]}) {

    count_primary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (categories -> 'primary' ->> 'name') IN (?) AND (personas -> 'primary' ->> 'score')::numeric >= 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 5)", user.personas_primary_name, filters[:categories], DateTime.now - 1]).count
    count_secondary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (categories -> 'primary' ->> 'name') IN (?) AND (personas -> 'primary' ->> 'score')::numeric >= 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 4)", user.personas_secondary_name, filters[:categories], DateTime.now - 1]).count + (5 - count_primary_persona)
    count_tertiary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (categories -> 'primary' ->> 'name') IN (?) AND  (personas -> 'primary' ->> 'score')::numeric >= 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 2)", user.personas_tertiary_name, filters[:categories], DateTime.now - 1]).count + (((4 + count_secondary_persona) - count_primary_persona) >= 0 ? (4 + count_secondary_persona) - count_primary_persona : 0)
    count_quartenary_persona = Event.find_by_sql(["(SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (categories -> 'primary' ->> 'name') IN (?) AND (personas -> 'primary' ->> 'score')::numeric >= 0.35 AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') LIMIT 2)", user.personas_quartenary_name, filters[:categories], DateTime.now - 1]).count + (((2 + count_tertiary_persona) - count_secondary_persona) >= 0 ? (2 + count_tertiary_persona) - count_secondary_persona : 0)

    find_by_sql(["
      SELECT events.* FROM
      ((SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND (categories -> 'primary' ->> 'name') NOT IN ('curso') AND (categories -> 'primary' ->> 'name') IN (?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') ORDER BY (personas -> 'primary' ->> 'score')::numeric DESC LIMIT ?)
      UNION
      (SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND (categories -> 'primary' ->> 'name') NOT IN ('curso') AND (categories -> 'primary' ->> 'name') IN (?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') ORDER BY (personas -> 'primary' ->> 'score')::numeric DESC LIMIT ?)
      UNION
      (SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND (categories -> 'primary' ->> 'name') NOT IN ('curso') AND (categories -> 'primary' ->> 'name') IN (?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') ORDER BY (personas -> 'primary' ->> 'score')::numeric DESC LIMIT ?)
      UNION
      (SELECT events.* FROM (SELECT DISTINCT ON (events.id) * FROM events) events WHERE ((personas -> 'primary' ->> 'name') = ? AND (ocurrences -> 'dates' ->> 0)::timestamptz > ?) AND (categories -> 'primary' ->> 'name') NOT IN ('curso') AND (categories -> 'primary' ->> 'name') IN (?) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false') ORDER BY (personas -> 'primary' ->> 'score')::numeric DESC LIMIT ?))
      AS events ORDER BY (ocurrences -> 'dates' ->> 0) ASC  LIMIT 15",
      user.personas_primary_name,
      DateTime.now - 1,
      filters[:categories],
      count_primary_persona,
      user.personas_secondary_name,
      DateTime.now - 1,
      filters[:categories],
      count_secondary_persona,
      user.personas_tertiary_name,
      DateTime.now - 1,
      filters[:categories],
      count_tertiary_persona,
      user.personas_quartenary_name,
      DateTime.now - 1,
      filters[:categories],
      count_quartenary_persona])
  }

  scope 'order_by_score', -> {
    order("(personas -> 'primary' ->> 'score')::numeric DESC")
  }

  scope 'in_days', -> (ocurrences) {
    return nil unless ocurrences

    if ocurrences.include?('hoje') && ocurrences.include?('amanhã')
      where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) BETWEEN ? AND ?", DateTime.now.yday, DateTime.now.yday + 1)
    elsif ocurrences.include? 'hoje'
      where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) = ?", DateTime.now.yday)
    elsif ocurrences.include? 'amanhã'
      where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) = ?", DateTime.now.yday + 1)
    end
  }

  scope 'order_by_date', -> (direction = 'ASC') {
    case direction
    when 'ASC' 
      order("(ocurrences -> 'dates' ->> 0) ASC") 
    when 'DESC' 
      order("(ocurrences -> 'dates' ->> 0) DESC")
    end
  }

  scope 'by_persona', -> (persona) { 
    where("((personas ->> 'outlier') IS NULL OR (personas ->> 'outlier') = 'false') AND (personas -> 'primary' ->> 'name') = ?", persona)
  }

  scope 'by_category', -> (category) { 
    where("(categories -> 'primary' ->> 'name') = ? AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false')", category) 
  }

  scope 'active', -> {
    where("(ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now - 1)
  }

  scope 'with_low_score', -> (feature) {
    case feature
    when :personas
      where("(personas -> 'primary' ->> 'score')::numeric < 0.51")
    when :categories
      where("(categories -> 'primary' ->> 'score')::numeric < 0.51")
    end
  }

  scope 'not_retrained', -> {
    where("(categories -> 'primary' ->> 'score')::numeric < 0.90 OR (personas -> 'primary' ->> 'score')::numeric < 0.90")
  }

  def personas_primary_name
    self.personas["primary"]["name"]
  end

  def personas_primary_name= value
    self.personas["primary"]["name"] = value
  end

  def personas_secondary_name
    self.personas["secondary"]["name"]
  end

  def personas_secondary_name= value
    self.personas["secondary"]["name"] = value
  end

  def personas_primary_score
    self.personas["primary"]["score"]
  end

  def personas_primary_score= value
    self.personas["primary"]["score"] = value
  end

  def personas_secondary_score
    self.personas["secondary"]["score"]
  end

  def personas_secondary_score= value
    self.personas["secondary"]["score"] = value
  end

  def categories_primary_name
    self.categories["primary"]["name"]
  end

  def categories_primary_name= value
    self.categories["primary"]["name"] = value
  end

  def categories_secondary_name
    self.categories["secondary"]["name"]
  end

  def categories_secondary_name= value
    self.categories["secondary"]["name"] = value
  end

  def categories_primary_score
    self.categories["primary"]["score"]
  end

  def categories_primary_score= value
    self.categories["primary"]["score"] = value
  end

  def categories_secondary_score
    self.categories["secondary"]["score"]
  end

  def categories_secondary_score= value
    self.categories["secondary"]["score"] = value
  end

  def personas_outlier
    self.personas["outlier"]
  end

  def personas_outlier= value
    self.personas["outlier"] = value
  end

  def categories_outlier
    self.categories["outlier"]
  end

  def categories_outlier= value
    self.categories["outlier"] = value
  end

  def neighborhood
    self.geographic["neighborhood"]
  end

  def neighborhood= value
    self.geographic["neighborhood"] = value
  end

  def cover_url
    if self.cover.attached?
      rails_blob_path(self.cover, disposition: "attachment", only_path: true)
    end
  end


  def url
    return event_path(self)
  end


  def day_time
    return self.dates.first
  end


  def day_of_week
    Alegreme::Dates.get_next_day_occur_human_readable(self)
  end


  def datetimes
    datetimes = []

    self.ocurrences['dates'].each_with_index do |date, index|
      datetimes << DateTime.parse(date).strftime("%Y-%m-%d %H:%M:%S")
    end

    return datetimes
  end


  private

  def destroy_entries
    users = User.where id: self.saved_by

    users.each do |user|
      user.taste['events']['saved'].delete self.id
      user.taste['events']['total_saves'] -= 1
    end
  end

end
