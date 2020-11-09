class Organizer < ApplicationRecord
	extend FriendlyId
	friendly_id :details_name, use: :slugged

	include OrganizerImageUploader::Attachment.new(:image)

	validate :uniq_details_name, on: :create

	has_and_belongs_to_many :events, touch: true
	has_many :follows, as: :following

	def details_name
		self.details['name']
	end

	def details_name=(value)
		self.details['name'] = value
	end


	private

	def uniq_details_name
		if Organizer.where("lower(details ->> 'name') = ?", details_name&.downcase).present?
			errors.add(:details_name, "O nome do organizador precisa ser único")
		end
	end

end
