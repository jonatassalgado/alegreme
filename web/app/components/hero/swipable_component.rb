class Hero::SwipableComponent < ViewComponentReflex::Component

  def initialize(user:, events:)
    @user   = user
    @events = events
  end

end