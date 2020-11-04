class UserChipSmallComponent < ViewComponentReflex::Component
	with_collection_parameter :friend

	def initialize(user:, friend:)
		@user         = user
		@friend       = friend
		@editing      = false
		@loading_edit = false
		@saving_edit  = false
	end

	def begin_edit
		@loading_edit = true
		refresh!
		@editing = true
		refresh!
		@loading_edit = false
	end

	def commit_edit
		@saving_edit = true
		refresh!
		Friendship.create_between_users(@user, @friend, element['data-friendship-action'])
		@saving_edit = false
	end

	def edited
		end_edit
		refresh! '#friends-list'
	end

	def end_edit
		@editing = false
	end

	# before_reflex :before_begin_edit, only: [:begin_edit]
	# after_reflex :after_begin_edit, only: [:begin_edit]
	#
	# def before_begin_edit
	# 	@loading[:begin_edit] = true
	# end
	#
	# def after_begin_edit
	# 	@loading[:begin_edit] = false
	# end

	def collection_key
		@friend.id
	end
end