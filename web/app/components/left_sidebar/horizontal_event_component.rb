class LeftSidebar::HorizontalEventComponent < ViewComponent::Base
	with_collection_parameter :likeable

	def initialize(likeable:, user:, parent_key: nil)
		@parent_key = parent_key
		@likeable   = likeable
		@user       = user
	end

	def collection_key
		@likeable.id
	end
end