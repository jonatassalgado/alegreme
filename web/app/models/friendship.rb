class Friendship < ApplicationRecord
	enum status: {
			requested: 0,
			accepted:  1,
			refused:   2
	}

	validates :user_id, uniqueness: {scope: :friend_id}
	validates :friend_type, inclusion: {in: %w(Friend)}
	validates :status, presence: :true, inclusion: {in: %w(requested)}, on: :create
	validates :status, presence: :true, inclusion: {in: %w(accepted refused)}, if: Proc.new { |friendship| friendship.changed? && friendship.status_was == 'requested' }
	validate :max_number_of_friends

	def max_number_of_friends
		if user.friendships_accepted.size >= 10 || friend.friendships_accepted.size >= 10
			errors.add(:user_id, "Você só pode adicionar 10 amigos")
		end
	end

	belongs_to :user
	belongs_to :friend, class_name: 'User'

	def self.find_between_users(user_a, user_b)
		Friendship.find_by(user_id: [user_a.id, user_b.id], friend_id: [user_b.id, user_a.id], friend_type: 'Friend')
	end

	def self.create_between_users(user, friend, friendship_action)
		if friendship_action == 'request'
			user.friendship_request! friend
		elsif friendship_action == 'accept'
			user.friendship_accept! friend
		elsif friendship_action == 'refuse'
			user.friendship_refused! friend
		elsif friendship_action == 'cancel'
			user.friendship_destroy! friend
		else
			false
		end
	end

end
