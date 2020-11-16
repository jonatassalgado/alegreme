class MainSidebar::HorizontalEventComponent < ViewComponentReflex::Component
  with_collection_parameter :event

  def initialize(event:, user:, parent_key: nil)
    @event      = event
    @user       = user
    @parent_key = parent_key
    @opened     = false
  end

  def like
    unless @user
      stimulate('Modal::SignInComponent#open', {key: 'modal-sign-in', text: "Crie uma conta para salvar eventos favoritos e receber recomendações únicas"})
      prevent_refresh!
    else
      if @user.like? @event
        @user.unlike! @event
      elsif @user.dislike? @event
        @user.like_update(@event, sentiment: :positive)
      else
        @user.like! @event
      end
    end
    refresh!
  end

  def dislike
    unless @user
      stimulate('Modal::SignInComponent#open', {key: 'modal-sign-in', text: "Crie uma conta para salvar eventos favoritos e receber recomendações únicas"})
      prevent_refresh!
    else
      if @user.dislike? @event
        @user.unlike! @event
      elsif @user.like? @event
        @user.like_update(@event, sentiment: :negative)
      else
        @user.dislike! @event
      end
    end
    refresh!
  end

  def open_event
    @opened = true
  end

  def close_event
    @opened = false
  end

  def collection_key
    @event.id
  end

end