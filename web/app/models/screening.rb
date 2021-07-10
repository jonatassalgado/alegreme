class Screening < ApplicationRecord
	validates :day, presence: true
	validates :times, presence: true, allow_blank: true
	validates_associated :movie, :cinema

	belongs_to :cinema
	belongs_to :movie
end