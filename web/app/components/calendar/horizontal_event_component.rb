class Calendar::HorizontalEventComponent < ViewComponent::Base
	with_collection_parameter :likeable

	def initialize(likeable:, user:, open_in_sidebar: false)
		@likeable        = likeable
		@user            = user
		@open_in_sidebar = open_in_sidebar
		@opened          = false
	end

	def collection_key
		@likeable.id
	end

end