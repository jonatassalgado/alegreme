class MainSidebar::HorizontalEventComponent < ViewComponentReflex::Component
	with_collection_parameter :event

	def initialize(event:, user:)
		@event  = event
		@user   = user
		@opened = false
	end

	def like
		if @user.like? @event
			@user.unlike! @event
		elsif @user.dislike? @event
			@user.like_update(@event, sentiment: :positive)
		else
			@user.like! @event
		end
		refresh!
	end

	def dislike
		if @user.dislike? @event
			@user.unlike! @event
		elsif @user.like? @event
			@user.like_update(@event, sentiment: :negative)
		else
			@user.dislike! @event
		end
		refresh!
	end

	def open_event
		@opened = true
	end

	def close_event
		@opened = false
	end

	def collection_key
		@event.id
	end

end