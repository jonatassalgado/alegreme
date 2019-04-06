class Event < ApplicationRecord
  require "day_of_week"

  include Rails.application.routes.url_helpers

  belongs_to :place
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :organizers

  has_one_attached :cover

  accepts_nested_attributes_for :place, :categories, :organizers

  delegate :name, :address, to: :place, prefix: true, allow_nil: true

  jsonb_accessor :ocurrences, dates: [:datetime, array: true, default: []]


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


  acts_as_favoritable


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
