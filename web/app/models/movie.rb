class Movie < ApplicationRecord

	COLLECTIONS = ['new release', 'editors choice'].sort.freeze
	GENRES      = ['Ação',
	               'Aventura',
	               'Animação',
	               'Comédia',
	               'Crime',
	               'Documentário',
	               'Drama',
	               'Família',
	               'Fantasia',
	               'História',
	               'Terror',
	               'Música',
	               'Mistério',
	               'Romance',
	               'Ficção científica',
	               'Cinema TV',
	               'Thriller',
	               'Guerra',
	               'Faroeste'].freeze

	extend FriendlyId

	include MovieImageUploader::Attachment.new(:image)

	include MovieDecorators::Streamings
	include MovieDecorators::Collections

	include Scopes
	include MovieQueries::Scopes

	friendly_id :title, use: :slugged

	def url
		movie_path(self)
	end

end
