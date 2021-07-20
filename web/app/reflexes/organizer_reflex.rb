# frozen_string_literal: true

class OrganizerReflex < ApplicationReflex

	def follow
		if current_user
			@organizer = Organizer.find element['data-followable-id']
			@type      = element['data-type']

			if current_user.follow? @organizer
				current_user.unfollow! @organizer
			else
				current_user.follow! @organizer
			end
			morph "#{dom_id(@organizer, 'follow-button')}", render(FollowButtonComponent.new(followable: @organizer, user: current_user, type: @type))
		else
			show_login_modal
		end
	end

	private

	def show_login_modal
		morph '#modal', render(Modal::SignInComponent.new(
			text:   "Crie uma conta para seguir organizadores",
			opened: true))
	end

end
