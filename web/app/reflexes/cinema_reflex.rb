# frozen_string_literal: true

class CinemaReflex < ApplicationReflex

	def follow
		if current_user
			@cinema = Cinema.find element['data-followable-id']
			@type   = element['data-type']

			if current_user.follow? @cinema
				current_user.unfollow! @cinema
			else
				begin
					current_user.follow! @cinema
				rescue StandardError => invalid
					show_modal 'Lá se foi sua cota', 'Você só pode seguir até 2 cinemas. Vamos manter as coisas simples por aqui 😜'
				end
			end
			morph "#{dom_id(@cinema, 'follow-button')}", render(FollowButtonComponent.new(followable: @cinema, user: current_user, type: @type))
		else
			show_modal 'Você precisa estar logado', 'Crie uma conta para seguir cinemas', 'create-account'
		end

	end

	private

	def show_modal(title, text, action = nil)
		morph '#modal', render(ModalComponent.new(
			title:  title,
			text:   text,
			action: action,
			opened: true))
	end

end
