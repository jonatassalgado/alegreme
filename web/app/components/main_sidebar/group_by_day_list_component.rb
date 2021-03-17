class MainSidebar::GroupByDayListComponent < ViewComponent::Base

  def initialize(events:, user:, open_in_sidebar: false, filters: {category: []})
    @events          = events.in_categories(filters[:category]).includes(:categories)
    @user            = user
    @open_in_sidebar = open_in_sidebar
  end

  def render?
    @events.present?
  end

end