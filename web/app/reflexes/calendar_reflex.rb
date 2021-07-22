# frozen_string_literal: true

class CalendarReflex < ApplicationReflex

	before_reflex :set_user

	def prev_month
		unless @user
			# stimulate('Modal::SignInComponent#open', { text: "Crie uma conta para salvar seus eventos favoritos e receber recomendações únicas"})
			# prevent_refresh!
		else
			start_date = date_range.first - 1.day
			morph '#calendar', render(CalendarComponent.new(
				events:     liked_events,
				start_date: start_date,
				user:       current_user,
				filter:     false,
				indicators: indicators))
		end
	end

	def next_month
		unless @user
			# stimulate('Modal::SignInComponent#open', { text: "Crie uma conta para salvar seus eventos favoritos e receber recomendações únicas"})
			# prevent_refresh!
		else
			start_date = date_range.last + 1.day
			morph '#calendar', render(CalendarComponent.new(
				events:     liked_events,
				start_date: start_date,
				user:       current_user,
				filter:     false,
				indicators: indicators))
		end
	end

	def in_day
		unless @user
			# stimulate('Modal::SignInComponent#open', { text: "Crie uma conta para salvar eventos na sua agenda"})
			# prevent_refresh!
		else
			morph '#calendar', render(CalendarComponent.new(
				events:     liked_events.in_day(element['data-day'].to_date),
				start_date: element['data-day'].to_date,
				user:       current_user,
				filter:     true,
				indicators: indicators))
		end
	end

	def clear_filter
		morph '#calendar', render(CalendarComponent.new(
			events:     liked_events,
			start_date: Date.today,
			user:       current_user,
			filter:     false,
			indicators: indicators))
	end

	def update
		morph '#calendar', render(CalendarComponent.new(
			events:     liked_events,
			start_date: Date.today,
			user:       current_user,
			filter:     false,
			indicators: indicators))
	end

	def like
		if current_user
			@event = Event.find element['data-event-id'] if element['data-event-id']

			if current_user.like? @event
				current_user.unlike! @event
			elsif current_user.dislike? @event
				current_user.like! @event, action: :update
			else
				current_user.like! @event
			end
			morph '#calendar', render(CalendarComponent.new(
				events:     liked_events,
				start_date: Date.today,
				user:       current_user,
				filter:     false,
				indicators: indicators))
		else
			show_login_modal
		end
	end

	def dislike
		if current_user
			@event = Event.find element['data-event-id'] if element['data-event-id']

			if current_user.dislike? @event
				current_user.unlike! @event
			elsif current_user.like? @event
				current_user.dislike! @event, action: :update
			else
				current_user.dislike! @event
			end
			morph '#calendar', render(CalendarComponent.new(
				events:     liked_events,
				start_date: Date.today,
				user:       current_user,
				filter:     false,
				indicators: indicators))
		else
			show_login_modal
		end
	end

	def unlike
		if current_user
			@event = Event.find element['data-event-id'] if element['data-event-id']

			if current_user.like_or_dislike? @event
				current_user.unlike! @event

				morph '#calendar', render(CalendarComponent.new(
					events:     liked_events,
					start_date: Date.today,
					user:       current_user,
					filter:     false,
					indicators: indicators))
			end
		else
			morph '#modal', render(ModalComponent.new(
				title:  'Você precisa estar logado',
				text:   'Crie uma conta para salvar seus eventos favoritos e receber recomendações únicas 🤙',
				action: 'create-account',
				opened: true))
		end
	end

	private

	# def get_component
	# 	reflex_controller.gsub(/-(.)/) { |c| c.upcase }.gsub(/--/, '/').gsub(/-/, '').camelize.concat("Component").constantize
	# end

	def indicators
		liked_events&.map(&:start_time)
	end

	def set_user
		@user = current_user
	end

	def liked_events
		@user&.liked_events&.not_ml_data&.active&.order_by_date
	end

	def date_range
		(element['data-start-date'].to_date.beginning_of_month.beginning_of_week..element['data-start-date'].to_date.end_of_month.end_of_week).to_a
	end

end