class ScreeningGroup < ApplicationRecord
	validates :date, presence: true
	validates_associated :movie, :cinema

	belongs_to :cinema
	belongs_to :movie, touch: true

	has_many :screenings, dependent: :nullify
	has_many :likes, as: :likeable, dependent: :destroy
	has_many :users, through: :likes, source: :likeable, source_type: 'ScreeningGroup'


	delegate :title, :image, :prices, :geographic, :categories, :trailer, :rating, :age_rating, :genres, :place_name, :multiple_hours, to: :movie
	alias_method :name, :title

	delegate :display_name, to: :cinema, prefix: true

	scope 'active', -> { includes(:cinema).where("screening_groups.date >= ? AND cinemas.status = 1", DateTime.now).references(:cinema) }

	def start_time
		date.to_datetime.midday.in_time_zone rescue nil
	end

end