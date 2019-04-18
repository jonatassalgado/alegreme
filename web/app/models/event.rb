class Event < ApplicationRecord
  require "day_of_week"

  include Rails.application.routes.url_helpers

  belongs_to :place
  has_and_belongs_to_many :organizers

  has_one_attached :cover

  accepts_nested_attributes_for :place, :organizers

  delegate :name, :address, to: :place, prefix: true, allow_nil: true

  jsonb_accessor :ocurrences, dates: [:datetime, array: true, default: []]

  scope 'for_user', -> (user) {
    where("(personas -> 'primary' ->> 'name') IN (?, ?, ?, ?)", user.personas_primary_name, user.personas_secondary_name, user.personas_tertiary_name, user.personas_quartenary_name)
  }

  scope 'order_by_score', -> {
    order("(personas -> 'primary' ->> 'score')::numeric DESC")
  }

  scope 'order_by_date', -> {
    order("(ocurrences -> 'dates' ->> 0) ASC")
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


  def cover_url
    if self.cover.attached?
      return rails_blob_path(self.cover, disposition: "attachment", only_path: true)
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


end
