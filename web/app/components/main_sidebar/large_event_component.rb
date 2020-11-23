class MainSidebar::LargeEventComponent < ViewComponentReflex::Component

	def initialize(user:)
		@user = user
	end

	def open(args = {})
		@event = Event.find(args['event_id'])
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
			refresh!
			refresh! '#main-sidebar', '#my-agenda'
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
			refresh!
			refresh! '#main-sidebar', '#my-agenda'
		end
	end

end