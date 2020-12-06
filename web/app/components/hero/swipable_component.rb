class Hero::SwipableComponent < ViewComponentReflex::Component

  def initialize(user:, events:)
    @user           = user
    @events         = events
    @events_visible = events.size
    @events_liked   = user.liked_events.size
  end

  def decrease(args = {})
    @events_visible = @events_visible - 1
  end

end