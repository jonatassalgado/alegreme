class FriendshipButtonComponent < ViewComponent::Base
	def initialize(user:, friend:)
		@user    = user
		@friend  = friend
		@editing = false
	end

	def begin_edit
		@editing = true
	end

	def commit_edit
		if friendship(@user, @friend, element['data-friendship-action'])
			end_edit
			refresh! '#page'
		end
	end

	def end_edit
		@editing = false
	end

	def friendship(user, friend, action)
		Friendship.create_between_users(user, friend, action)
	end

end

