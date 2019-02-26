class Event < ApplicationRecord
  require "day_of_week"

  include Rails.application.routes.url_helpers

  belongs_to :place
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :calendars
  has_and_belongs_to_many :organizers

  has_one_attached :cover

  accepts_nested_attributes_for :calendars, :place, :categories, :organizers

  acts_as_favoritable

  def cover_url
    return rails_blob_path(self.cover, disposition: "attachment", only_path: true)
  end

  def url
    return event_path(self)
  end

  def day_time
    return calendars.first.day_time
  end

  def day_of_week
    Alegreme::Dates.get_next_day_occur_human_readable(self)
  end


end
