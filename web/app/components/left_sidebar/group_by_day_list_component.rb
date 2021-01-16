class LeftSidebar::GroupByDayListComponent < ViewComponent::Base

	def initialize(events:, user:, parent_key: nil)
		@parent_key = parent_key
		@events     = events
		@user       = user
	end

end