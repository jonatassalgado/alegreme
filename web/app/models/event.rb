class Event < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :place
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :calendars
  has_and_belongs_to_many :organizers

  has_one_attached :cover

  acts_as_favoritable

  def cover_url
    return rails_blob_path(self.cover, disposition: "attachment", only_path: true)
  end

  def url
    return event_path(self)
  end

end
