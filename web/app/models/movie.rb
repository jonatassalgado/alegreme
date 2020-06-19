class Movie < ApplicationRecord

	COLLECTIONS = ['new release', 'editors choice'].sort.freeze

	extend FriendlyId

	include MovieImageUploader::Attachment.new(:image)

	include MovieDecorators::Streamings
	include MovieDecorators::Collections

	include Scopes
	include MovieQueries::Scopes

	friendly_id :details_title, use: :slugged

	def url
		movie_path(self)
	end

end
