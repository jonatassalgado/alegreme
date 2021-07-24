class LeftSidebar::GroupByDayListComponent < ViewComponent::Base

	def initialize(likeables:, user:, parent_key: nil)
		@parent_key = parent_key
		@likeables  = likeables
		@user       = user
	end

end