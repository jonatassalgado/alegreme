class Place < ApplicationRecord

  extend FriendlyId
  friendly_id :details_name, use: :slugged

  has_many :events

  #acts_as_followable

  def details_name
    self.details['name']
  end

  def details_name=(value)
    self.details['name'] = value
  end

  def geographic_address
    self.geographic['address']
  end
end
