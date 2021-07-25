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

	validates :title, uniqueness: true

	has_many :screenings, dependent: :destroy
	has_many :cinemas, -> { distinct }, through: :screenings

	friendly_id :title, use: :slugged

	def url
		movie_path(self)
	end

	def update_only_if_blank(attributes = {})
		attributes.each { |k, v| attributes.delete(k) unless read_attribute(k).blank? }
		update_attributes(attributes)
	end

end
