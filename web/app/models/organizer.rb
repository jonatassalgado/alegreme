class Organizer < ApplicationRecord
  has_and_belongs_to_many :events

  acts_as_followable
end
