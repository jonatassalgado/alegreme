class Hero::TrainEventComponent < ViewComponent::Base
  with_collection_parameter :event

  def initialize(event:, user:, parent_key: nil, open_in_sidebar: false)
    @event           = event
    @user            = user
    @parent_key      = parent_key
    @open_in_sidebar = open_in_sidebar
    @opened          = false
  end

  def collection_key
    @event.id
  end

end