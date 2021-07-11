class Cinema < ApplicationRecord

	extend FriendlyId

	validates :google_maps, uniqueness: true

	has_many :screenings, dependent: :destroy
	has_many :movies, -> { distinct }, through: :screenings, dependent: :destroy

	friendly_id :name, use: :slugged
end