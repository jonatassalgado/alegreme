class Like < ApplicationRecord
	belongs_to :user
	belongs_to :event

	validates :user_id, uniqueness: {scope: :event_id}
	validates :sentiment, presence: :true, inclusion: {in: %w(positive negative)}
end
