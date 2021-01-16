class LargeEventComponent < ViewComponent::Base
	with_collection_parameter :event

	def initialize(event:, user:)
		@event  = event
		@user   = user
	end

	def collection_key
		@event.id
	end
end