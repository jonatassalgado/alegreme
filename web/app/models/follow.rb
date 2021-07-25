class Follow < ApplicationRecord
	validates :user_id, uniqueness: { scope: [:following_id, :following_type] }
	validates :following_type, presence: :true, inclusion: { in: %w(User Place Organizer Cinema) }
	validate :max_number_of_cinemas

	belongs_to :follower, foreign_key: :user_id, class_name: 'User'
	belongs_to :following, polymorphic: true

	private

	def max_number_of_cinemas
		if following.class.base_class == Cinema && follower.following_cinemas&.size >= 2
			errors.add(:base, :max_number_of_following_cinemas, message: "Você só pode seguir até 2 cinemas")
		end
	end
end
