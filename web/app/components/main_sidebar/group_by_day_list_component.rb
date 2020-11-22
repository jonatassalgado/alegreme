class MainSidebar::GroupByDayListComponent < ViewComponentReflex::Component

  def initialize(events:, user:, parent_key: nil, open_in_sidebar: false)
    @events          = events
    @user            = user
    @parent_key      = parent_key
    @open_in_sidebar = open_in_sidebar
  end

end