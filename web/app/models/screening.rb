class Screening < ApplicationRecord
	validates :day, presence: true
	validates :times, presence: true, allow_blank: true
	validates_associated :movie, :cinema

	belongs_to :cinema
	belongs_to :movie, touch: true

	has_many :likes, as: :likeable, dependent: :destroy
	has_many :users, through: :likes, source: :likeable, source_type: 'Screening'

	alias_attribute :start_time, :day

	delegate :title, :image, to: :movie
	alias_method :name, :title

	scope 'active', -> { includes(:cinema).where("screenings.day >= ? AND cinemas.status = 1", DateTime.now).references(:cinema) }
end