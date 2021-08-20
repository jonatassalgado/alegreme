class MainSidebar::FilterComponent < ViewComponent::Base

	def initialize(session:, show_filter_group: nil, filters: { theme: 'entretenimento-lazer' }, open: false, params: nil)
		@params              = params
		@open                = open
		@filters             = Rails.cache.fetch("#{session}/main-sidebar--filter/filters", { expires_in: 1.hour, skip_nil: true }) { filters }
		@categories          = Category.select("categories.id, categories.details, COUNT(events.id) as active_events_count").joins(:events).where("events.datetimes[1] > ?", DateTime.now).group("categories.id")
		@categories_filtered = Category.where(id: @filters[:categories])
		@show_filter_group   = show_filter_group
	end

	def categories_or_date_presents?
		@filters[:categories].present? || @filters[:date].present?
	end
end