class Organizer < ApplicationRecord
  extend FriendlyId
  friendly_id :details_name, use: :slugged

  has_and_belongs_to_many :events, touch: true

  #acts_as_followable

  def details_name
    self.details['name']
  end

  def details_name=(value)
    self.details['name'] = value
  end
end
