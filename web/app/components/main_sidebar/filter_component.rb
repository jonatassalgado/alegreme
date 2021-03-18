class MainSidebar::FilterComponent < ViewComponent::Base

	def initialize(session:, show_filter_group:, filters:, params: nil)
		@params            = params
		@categories        = Category.where("(details ->> 'name') NOT IN (?)", ['outlier'])
		@show_filter_group = show_filter_group
		@filters           = Rails.cache.fetch("#{session}/main-sidebar--filter/filters", { expires_in: 1.hour, skip_nil: true }) { filters }
	end

end