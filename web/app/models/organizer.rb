class Organizer < ApplicationRecord
	extend FriendlyId
	friendly_id :details_name, use: :slugged

	has_and_belongs_to_many :events, touch: true
	has_many :follows, as: :following

	def details_name
		self.details['name']
	end

	def details_name=(value)
		self.details['name'] = value
	end
end
