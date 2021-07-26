# frozen_string_literal: true

class OrganizerReflex < ApplicationReflex

	def follow
		if current_user
			@organizer = Organizer.find element['data-followable-id']
			@type      = element['data-type']

			if current_user.follow? @organizer
				current_user.unfollow! @organizer
			else
				begin
					current_user.follow! @organizer
				rescue StandardError => invalid
					show_modal 'Lá se foi sua cota', 'Você só pode seguir até 5 organizadores. Vamos manter as coisas simples por aqui 😜'
				end
			end
			morph "#{dom_id(@organizer, 'follow-button')}", render(FollowButtonComponent.new(followable: @organizer, user: current_user, type: @type))
		else
			show_modal 'Você precisa estar logado', 'Crie uma conta para seguir organizadores', 'create-account'
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
