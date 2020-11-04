class MainSidebar::GroupByDayListComponent < ViewComponentReflex::Component

	def initialize(events:, user:)
		@events = events
		@user  = user
	end

end