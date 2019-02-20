module FeedsHelper

  def favorited(event)
    unless current_user
      return false
    end
    current_user.favorited?(event, scope: ['favorite'])
  end
end
