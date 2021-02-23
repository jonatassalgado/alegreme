class MainSidebar::FilterComponent < ViewComponent::Base

	def initialize(categories:)
		@categories = categories
	end

end