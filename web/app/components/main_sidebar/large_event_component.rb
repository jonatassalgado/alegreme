class MainSidebar::LargeEventComponent < ViewComponentReflex::Component

	def initialize(user:)
		@user = user
	end

	def open(args = {})
		@event          = Event.find(args['event_id'])
		@similar_events = Event.includes(:place).not_ml_data.active.not_disliked(@user).where(id: @event.similar_data).order_by_ids(@event.similar_data).not_liked(@user).limit(6)
	end

	def close
		@event = nil
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
				@user.dislike! @event, action: :update
			else
				@user.dislike! @event
			end
			refresh!
			refresh! '#main-sidebar', '#my-agenda'
		end
	end

end