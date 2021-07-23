# frozen_string_literal: true

class LeftSidebar::CalendarReflex < ApplicationReflex

	before_reflex :set_user

	def prev_month
		unless @user
			morph '#modal', render(ModalComponent.new(
				title:  'Você precisa estar logado',
				text:   'Crie uma conta para salvar seus eventos favoritos e receber recomendações únicas 🤙',
				action: 'create-account',
				opened: true))
		else
			start_date = date_range.first - 1.day
			morph '#calendar', render(LeftSidebar::CalendarComponent.new(
				events:     liked_resources,
				start_date: start_date,
				user:       current_user,
				filter:     false,
				indicators: indicators))
		end
	end

	def next_month
		unless @user
			morph '#modal', render(ModalComponent.new(
				title:  'Você precisa estar logado',
				text:   'Crie uma conta para salvar seus eventos favoritos e receber recomendações únicas 🤙',
				action: 'create-account',
				opened: true))
		else
			start_date = date_range.last + 1.day
			morph '#calendar', render(LeftSidebar::CalendarComponent.new(
				events:     liked_resources,
				start_date: start_date,
				user:       current_user,
				filter:     false,
				indicators: indicators))
		end
	end

	def in_day
		unless @user
			morph '#modal', render(ModalComponent.new(
				title:  'Você precisa estar logado',
				text:   'Crie uma conta para salvar seus eventos favoritos e receber recomendações únicas 🤙',
				action: 'create-account',
				opened: true))
		else
			morph '#calendar', render(LeftSidebar::CalendarComponent.new(
				events:     liked_resources_in_day(element['data-day'].to_date),
				start_date: element['data-day'].to_date,
				user:       current_user,
				filter:     true,
				indicators: indicators))
		end
	end

	def clear_filter
		morph '#calendar', render(LeftSidebar::CalendarComponent.new(
			events:     liked_resources,
			start_date: Date.today,
			user:       current_user,
			filter:     false,
			indicators: indicators))
	end

	def update
		morph '#calendar', render(LeftSidebar::CalendarComponent.new(
			events:     liked_resources,
			start_date: Date.today,
			user:       current_user,
			filter:     false,
			indicators: indicators))
	end

	def unlike
		if current_user
			@type     = element['data-likeable-type'].classify.safe_constantize
			@likeable = @type.find(element['data-likeable-id']) if element['data-likeable-id']

			if current_user.like_or_dislike? @likeable
				current_user.unlike! @likeable

				morph '#calendar', render(LeftSidebar::CalendarComponent.new(
					events:     liked_resources,
					start_date: Date.today,
					user:       current_user,
					filter:     false,
					indicators: indicators))

				return if @type != Event

				morph "#{dom_id(@likeable, 'main-sidebar')}", render(MainSidebar::HorizontalEventComponent.new(
					event:           @likeable,
					user:            current_user,
					open_in_sidebar: true))
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
		(@user&.liked_events&.not_ml_data&.active&.order_by_date || Event.none) + (current_user&.liked_screenings || Screening.none)
	end

	def liked_resources_in_day day
		(@user&.liked_events&.not_ml_data&.active&.in_day(day)&.order_by_date || Event.none) + (current_user&.liked_screenings&.where("day = ?", day) || Screening.none)
	end

	def date_range
		(element['data-start-date'].to_date.beginning_of_month.beginning_of_week..element['data-start-date'].to_date.end_of_month.end_of_week).to_a
	end

end