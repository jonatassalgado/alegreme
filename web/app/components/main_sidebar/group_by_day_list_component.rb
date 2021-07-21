class MainSidebar::GroupByDayListComponent < ViewComponent::Base

	def initialize(events:, user:, filters: {}, pagy:, open_in_sidebar: false)
		@events          = events
		@user            = user
		@open_in_sidebar = open_in_sidebar
		@filters         = filters || Rails.cache.read("#{session.id}/main-sidebar--filter/filters")
		@pagy            = pagy
	end

	def render?
		@events.present?
	end

end