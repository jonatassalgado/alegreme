# frozen_string_literal: true

class SwipableReflex < ApplicationReflex

	def like
		if current_user
			Rails.cache.increment("#{current_user.cache_key}/hero--swipable/suggestions_viewed", 1, { expires_in: 1.hour})
			@event = Event.find element['data-event-id']
			current_user.like! @event

			morph '#swipable', render(Hero::SwipableComponent.new(user: current_user))
		else
			morph '#modal', render(ModalComponent.new(
				title:  'Você precisa estar logado',
				text:   'Crie uma conta para salvar seus eventos favoritos e receber recomendações únicas 🤙',
				action: 'create-account',
				opened: true))
		end
	end

	def dislike

		if current_user
			@event = Event.find element['data-event-id']

			if current_user.dislike? @event
				current_user.unlike! @event
			elsif current_user.like? @event
				current_user.dislike! @event, action: :update
			else
				current_user.dislike! @event
			end

			morph '#swipable', render(Hero::SwipableComponent.new(user: current_user))
		else
			morph '#modal', render(ModalComponent.new(
				title:  'Você precisa estar logado',
				text:   'Crie uma conta para salvar seus eventos favoritos e receber recomendações únicas 🤙',
				action: 'create-account',
				opened: true))
		end
	end

	def hide_swipable
		update_swipable_hidden_at
		morph '#swipable', render(Hero::SwipableComponent.new(user: current_user))
	end

	private

	def update_swipable_hidden_at
		current_user.swipable.deep_merge!({
																				'events' => {
																					'hidden_at' => DateTime.now
																				}
																			})
		current_user.save
	end

end