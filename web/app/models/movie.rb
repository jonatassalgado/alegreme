class Movie < ApplicationRecord

	include MovieImageUploader::Attachment.new(:image)

	extend FriendlyId
	friendly_id :details_title, use: :slugged

	include MovieDecorators::Streamings

end
