class Hero::TabsComponent < ViewComponentReflex::Component

  def initialize(user:, selected_tab:, suggested_events:)
    @user             = user
    @selected_tab     = selected_tab
    @suggested_events = suggested_events
  end

  def select
    @selected_tab = element['data-tab']
  end


end