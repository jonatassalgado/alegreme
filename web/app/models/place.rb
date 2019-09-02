class Place < ApplicationRecord

  extend FriendlyId
  friendly_id :details_name, use: :slugged

  has_many :events

  def details_name
    self.details['name']
  end

  def details_name=(value)
    self.details['name'] = value
  end
end
