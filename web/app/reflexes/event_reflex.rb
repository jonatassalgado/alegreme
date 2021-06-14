# frozen_string_literal: true

class EventReflex < ApplicationReflex

	before_reflex :set_event

	def open
		morph '#main-sidebar--large-event', render(MainSidebar::LargeEventComponent.new(
			user:  current_user,
			event: @event))
	end

	def close
		morph '#main-sidebar--large-event', render(MainSidebar::LargeEventComponent.new(
			user:  current_user,
			event: nil))
	end

	def like
		if current_user
			if current_user.like? @event
				current_user.unlike! @event
			elsif current_user.dislike? @event
				current_user.like! @event, action: :update
			else
				current_user.like! @event
			end
			case element['data-component']
			when 'horizontal-event'
				morph_horizontal_event
			when 'large-event'
				morph_large_event
			end
		else
			show_login_modal
		end
	end

	def dislike
		if current_user
			if current_user.dislike? @event
				current_user.unlike! @event
			elsif current_user.like? @event
				current_user.dislike! @event, action: :update
			else
				current_user.dislike! @event
			end
			case element['data-component']
			when 'horizontal-event'
				morph_horizontal_event
			when 'large-event'
				morph_large_event
			end
		else
			show_login_modal
		end
	end

	def unlike
		if current_user
			if current_user.like_or_dislike? @event
				current_user.unlike! @event
			end
		else
			show_login_modal
		end
	end

	private

	def morph_horizontal_event
		morph "#{dom_id(@event, 'main-sidebar')}", render(MainSidebar::HorizontalEventComponent.new(
			event:           @event,
			user:            current_user,
			open_in_sidebar: true))
	end

	def morph_large_event
		morph "#{dom_id(@event)}", render(LargeEventComponent.new(
			event:           @event,
			user:            current_user))
	end

	def show_login_modal
		morph '#modal', render(Modal::SignInComponent.new(
			text:   "Crie uma conta para salvar eventos favoritos e receber recomendações únicas",
			opened: true))
	end

	def set_event
		@event = Event.includes(:categories, :organizers, :place).find(element['data-event-id']) if element['data-event-id']
	end

end
