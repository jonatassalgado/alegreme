# frozen_string_literal: true

class UserReflex < ApplicationReflex

	before_reflex :set_user, :set_type

	def follow
		if current_user
			if current_user.follow? @user
				current_user.unfollow! @user
			else
				begin
					current_user.follow! @user
				rescue StandardError => invalid
					show_modal 'Lá se foi sua cota', 'Você só pode seguir até 10 pessoas. Vamos manter as coisas simples por aqui 😜'
				end
			end
			morph "#{dom_id(@user, 'follow-button')}", render(FollowButtonComponent.new(followable: @user, user: current_user, type: @type))
		else
			show_modal 'Você precisa estar logado', 'Crie uma conta para seguir pessoas', 'create-account'
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

	def set_user
		@user = User.find element['data-followable-id']
	end

	def set_type
		@type = element['data-type']
	end

end
