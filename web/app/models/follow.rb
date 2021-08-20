class Follow < ApplicationRecord
	validates :user_id, uniqueness: { scope: [:following_id, :following_type] }
	validates :following_type, presence: :true, inclusion: { in: %w(User Place Organizer Cinema) }
	validate :max_number_of_users, if: -> (follow) { follow.following.class.base_class == User }
	validate :max_number_of_places, if: -> (follow) { follow.following.class.base_class == Place }
	validate :max_number_of_organizers, if: -> (follow) { follow.following.class.base_class == Organizer }
	validate :max_number_of_cinemas, if: -> (follow) { follow.following.class.base_class == Cinema }

	belongs_to :follower, foreign_key: :user_id, class_name: 'User'
	belongs_to :following, polymorphic: true

	private

	def max_number_of_users
		if following.class.base_class == User && follower.following_users&.size >= 10
			errors.add(:base, :max_number_of_following_users, message: "Você só pode seguir até 10 pessoas")
		end
	end

	def max_number_of_places
		if following.class.base_class == Place && follower.following_places&.size >= 5
			errors.add(:base, :max_number_of_following_places, message: "Você só pode seguir até 5 locais")
		end
	end

	def max_number_of_organizers
		if following.class.base_class == Organizer && follower.following_organizers&.size >= 5
			errors.add(:base, :max_number_of_following_organizers, message: "Você só pode seguir até 5 organizadores")
		end
	end

	def max_number_of_cinemas
		if following.class.base_class == Cinema && follower.following_cinemas&.size >= 2
			errors.add(:base, :max_number_of_following_cinemas, message: "Você só pode seguir até 2 cinemas")
		end
	end
end
