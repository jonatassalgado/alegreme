class LeftSidebar::HorizontalEventComponent < ViewComponent::Base
	with_collection_parameter :event

	def initialize(event:, user:, parent_key: nil)
		@parent_key = parent_key
		@event      = event
		@user       = user
	end

	def collection_key
		@event.id
	end
end