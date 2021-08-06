# frozen_string_literal: true

class TrainReflex < ApplicationReflex

	def like

		if current_user
			@event = Event.find element['data-event-id']

			if current_user.like? @event
				current_user.unlike! @event
			elsif current_user.dislike? @event
				current_user.like! @event, action: :update
			else
				current_user.like! @event
			end

			morph '#swipable', render(Hero::SwipableComponent.new(user: current_user))
		else
			morph '#modal', render(ModalComponent.new(
				title:  'Você precisa estar logado',
				text:   'Crie uma conta para salvar seus eventos favoritos e receber recomendações únicas 🤙',
				action: 'create-account',
				opened: true))

			morph '#swipable', render(Hero::SwipableComponent.new(user: nil))
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

			morph '#swipable', render(Hero::SwipableComponent.new(user: nil))
		end
	end

	def hide_train
		update_train_finished_at
		morph '#swipable', render(Hero::SwipableComponent.new(user: current_user))
	end

	private

	def update_train_finished_at
		current_user.swipable.deep_merge!({
																				'events' => {
																					'finished_at' => DateTime.now
																				}
																			})
		current_user.save
	end

end