class LargeEventComponent < ViewComponentReflex::Component
	with_collection_parameter :event

	def initialize(event:, user:)
		@event  = event
		@user   = user
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
	end

	def collection_key
		@event.id
	end
end