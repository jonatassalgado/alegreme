class Cinema < ApplicationRecord

	extend FriendlyId

	validates :address, uniqueness: true

	has_many :screenings, dependent: :destroy
	has_many :movies, through: :screenings, dependent: :destroy

	friendly_id :name, use: :slugged
end