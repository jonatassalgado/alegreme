class Hero::TrainEventComponent < ViewComponentReflex::Component
  with_collection_parameter :event

  def initialize(user:, event:)
    @user  = user
    @event = event
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
      refresh! '#main-sidebar__group-by-day-list', '#my-agenda'
    end
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
      refresh! '#main-sidebar__group-by-day-list', '#my-agenda'
    end
  end

  def collection_key
    @event.id
  end

end