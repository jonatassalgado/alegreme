class Hero::HorizontalEventComponent < ViewComponentReflex::Component
  with_collection_parameter :event

  def initialize(event:, user:, parent_key: nil, open_in_sidebar: false)
    @event           = event
    @user            = user
    @parent_key      = parent_key
    @open_in_sidebar = open_in_sidebar
    @opened          = false
  end

  def like
    unless @user
      stimulate('Modal::SignInComponent#open', {key: 'modal-sign-in', text: "Crie uma conta para salvar eventos favoritos e receber recomendações únicas"})
      prevent_refresh!
    else
      if @user.like? @event
        @user.unlike! @event
      elsif @user.dislike? @event
        @user.like! @event, action: :update
      else
        @user.like! @event
      end
    end
    prevent_refresh!
  end

  def dislike
    unless @user
      stimulate('Modal::SignInComponent#open', {key: 'modal-sign-in', text: "Crie uma conta para salvar eventos favoritos e receber recomendações únicas"})
      prevent_refresh!
    else
      if @user.dislike? @event
        @user.unlike! @event
      elsif @user.like? @event
        @user.dislike! @event, action: :update
      else
        @user.dislike! @event
      end
    end
    prevent_refresh!
  end

  def collection_key
    @event.id
  end

end