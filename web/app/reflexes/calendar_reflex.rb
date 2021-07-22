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
				events:     liked_resources,
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
				events:     liked_resources,
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
				events:     liked_resources.in_day(element['data-day'].to_date),
				start_date: element['data-day'].to_date,
				user:       current_user,
				filter:     true,
				indicators: indicators))
		end
	end

	def clear_filter
		morph '#calendar', render(CalendarComponent.new(
			events:     liked_resources,
			start_date: Date.today,
			user:       current_user,
			filter:     false,
			indicators: indicators))
	end

	def update
		morph '#calendar', render(CalendarComponent.new(
			events:     liked_resources,
			start_date: Date.today,
			user:       current_user,
			filter:     false,
			indicators: indicators))
	end

	def like
		if current_user
			@likeable = element['data-likeable-type'].classify.safe_constantize.find(element['data-likeable-id']) if element['data-likeable-id']

			if current_user.like? @likeable
				current_user.unlike! @likeable
			elsif current_user.dislike? @likeable
				current_user.like! @likeable, action: :update
			else
				current_user.like! @likeable
			end
			morph '#calendar', render(CalendarComponent.new(
				events:     liked_resources,
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
			@likeable = element['data-likeable-type'].classify.safe_constantize.find(element['data-likeable-id']) if element['data-likeable-id']

			if current_user.dislike? @likeable
				current_user.unlike! @likeable
			elsif current_user.like? @likeable
				current_user.dislike! @likeable, action: :update
			else
				current_user.dislike! @likeable
			end
			morph '#calendar', render(CalendarComponent.new(
				events:     liked_resources,
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
			@likeable = element['data-likeable-type'].classify.safe_constantize.find(element['data-likeable-id']) if element['data-likeable-id']

			if current_user.like_or_dislike? @likeable
				current_user.unlike! @likeable

				morph '#calendar', render(CalendarComponent.new(
					events:     liked_resources,
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
		liked_resources&.map(&:start_time)
	end

	def set_user
		@user = current_user
	end

	def liked_resources
		current_user&.liked_events&.not_ml_data&.active&.order_by_date + current_user.liked_screenings
	end

	def date_range
		(element['data-start-date'].to_date.beginning_of_month.beginning_of_week..element['data-start-date'].to_date.end_of_month.end_of_week).to_a
	end

end