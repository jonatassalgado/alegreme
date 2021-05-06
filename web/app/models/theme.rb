class Theme < ApplicationRecord
	has_many :categories
	has_many :events, through: :categories
end