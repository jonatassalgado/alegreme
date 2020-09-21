class Follow < ApplicationRecord
	validates :user_id, uniqueness: {scope: [:following_id, :following_type]}
	validates :following_type, presence: :true, inclusion: {in: %w(User Place Organizer)}

	belongs_to :follower, foreign_key: :user_id, class_name: 'User'
	belongs_to :following, polymorphic: true
end
