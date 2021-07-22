# frozen_string_literal: true

class LikesReflex < ApplicationReflex

	before_reflex :set_likeable

	def like
		if current_user
			begin
				if current_user.like? @likeable
					current_user.unlike! @likeable
				elsif current_user.dislike? @likeable
					current_user.like! @likeable, action: :update
				else
					current_user.like! @likeable
				end
			rescue StandardError => invalid
				show_modal 'Lá se foi sua cota', 'Você só pode salvar uma sessão por filme. Vamos manter as coisas simples por aqui 😜'
			end
			morph dom_id(@likeable, 'likes-button'), render(LikesButtonComponent.new(likeable: @likeable, user: current_user))
		else
			show_modal 'Você precisa estar logado', 'Crie uma conta para salvar seus filmes favoritos 🤙', 'create-account'
		end
	end

	def dislike
		if current_user
			if current_user.dislike? @likeable
				current_user.unlike! @likeable
			elsif current_user.like? @likeable
				current_user.dislike! @likeable, action: :update
			else
				current_user.dislike! @likeable
			end
			morph dom_id(@likeable, 'likes-button'), render(LikesButtonComponent.new(likeable: @likeable, user: current_user))
		else
			show_modal 'Você precisa estar logado', 'Crie uma conta para salvar seus filmes favoritos 🤙', 'create-account'
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

	def set_likeable
		@likeable = element['data-likeable-type'].classify.safe_constantize.find(element['data-likeable-id']) if element['data-likeable-id']
	end

end
