class MainSidebar::GroupByDayListComponent < ViewComponent::Base

  def initialize(events:, user:, open_in_sidebar: false)
    @events          = events
    @user            = user
    @open_in_sidebar = open_in_sidebar
  end

  def render?
    @events.present?
  end

end