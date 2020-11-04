class MainSidebar::LargeEventComponent < ViewComponentReflex::Component

	def initialize(event:, user:)
		@user = user
	end

	def open(args = {})
		@event = Event.find(args['event_id'])
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

end