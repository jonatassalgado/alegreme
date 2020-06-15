class Movie < ApplicationRecord

	COLLECTIONS = ['new release', 'editors choice'].sort.freeze

	extend FriendlyId

	include MovieImageUploader::Attachment.new(:image)

	include MovieDecorators::Streamings
	include MovieDecorators::Collections

	friendly_id :details_title, use: :slugged

end
