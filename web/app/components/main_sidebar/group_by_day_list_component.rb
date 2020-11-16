class MainSidebar::GroupByDayListComponent < ViewComponentReflex::Component

  def initialize(events:, user:, parent_key: nil)
    @events     = events
    @user       = user
    @parent_key = parent_key
  end

end