class MainSidebar::LargeEventComponent < ViewComponent::Base

	def initialize(user:, event:)
		@user           = user
		@event          = event
		@similar_events = Event.includes(:place, :categories).not_ml_data.active.where(id: @event.similar_data).order_by_ids(@event.similar_data).limit(6) if @event
	end

end