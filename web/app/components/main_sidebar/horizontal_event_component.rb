class MainSidebar::HorizontalEventComponent < ViewComponent::Base
  with_collection_parameter :event

  def initialize(event:, user:, open_in_sidebar: false)
    @event           = event
    @user            = user
    @open_in_sidebar = open_in_sidebar
    @opened          = false
  end

  def collection_key
    @event.id
  end

end