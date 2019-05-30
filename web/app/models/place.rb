class Place < ApplicationRecord
  has_many :events

  def details_name
    self.details['name']
  end

  def details_name=(value)
    self.details['name'] = value
  end
end
