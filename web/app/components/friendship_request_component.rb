class FriendshipRequestComponent < ViewComponent::Base
	with_collection_parameter :friend

	def initialize(user:, friend:)
		@user       = user
		@friend     = friend
		@friendship = Friendship.find_between_users(@user, @friend)
	end

	def reply
		Friendship.create_between_users(@user, @friend, element.dataset['friendship-action'])
		refresh!
		refresh! '#friends-list'
	end

	def collection_key
		@friend.id
	end
end