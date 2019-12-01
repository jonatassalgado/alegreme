class Movie < ApplicationRecord

	include MovieImageUploader::Attachment.new(:image)

	extend FriendlyId
	friendly_id :details_name, use: :slugged

	def details_name
		details['name']
	end

end
