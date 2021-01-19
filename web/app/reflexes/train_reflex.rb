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
			morph '#modal', render(Modal::SignInComponent.new(
				text:   "Crie uma conta para salvar eventos favoritos e receber recomendações únicas",
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
			morph '#modal', render(Modal::SignInComponent.new(
				text:   "Crie uma conta para salvar eventos favoritos e receber recomendações únicas",
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

	def show_swipable?
		if @user
			@show_swipable = (DateTime.now - @suggestion_hours_interval.hours) > @user.swipable.dig('events', 'hidden_at').to_datetime rescue true
			update_last_view_at if @show_swipable
		else
			@show_swipable = false
		end
	end

	def update_last_view_at
		current_user.swipable.deep_merge!({
																				'events' => {
																					'last_view_at' => DateTime.now
																				}
																			})
		current_user.save
	end

	def events_to_train_or_suggestions
		return unless current_user

		current_user.liked_or_disliked_events.reset
		if current_user.swipable['events']['finished_at'].blank? && current_user.liked_event_ids.size < @min_events_to_train
			@events_to_train = Event.not_ml_data.active.not_liked_or_disliked(current_user).order_by_date.limit(3)
		else
			@events_suggestions = Event.not_ml_data.active.in_user_suggestions(current_user).not_liked_or_disliked(current_user).limit(3)
		end
	end
end