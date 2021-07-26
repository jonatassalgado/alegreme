# frozen_string_literal: true

class PlaceReflex < ApplicationReflex

	def follow
		if current_user
			@place = Place.find element['data-followable-id']
			@type  = element['data-type']

			if current_user.follow? @place
				current_user.unfollow! @place
			else
				begin
					current_user.follow! @place
				rescue StandardError => invalid
					show_modal 'Lá se foi sua cota', 'Você só pode seguir até 5 locais. Vamos manter as coisas simples por aqui 😜'
				end
			end
			morph "#{dom_id(@place, 'follow-button')}", render(FollowButtonComponent.new(followable: @place, user: current_user, type: @type))
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
