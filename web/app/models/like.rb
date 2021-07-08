class Like < ApplicationRecord
	belongs_to :user
	belongs_to :likeable, polymorphic: true

	validates :user_id, uniqueness: {scope: :likeable_id}
	validates :sentiment, presence: :true, inclusion: {in: %w(positive negative)}
end
