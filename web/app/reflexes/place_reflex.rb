# frozen_string_literal: true

class PlaceReflex < ApplicationReflex

	def follow
		if current_user
			@place = Place.find element['data-followable-id']
			@type  = element['data-type']

			if current_user.follow? @place
				current_user.unfollow! @place
			else
				current_user.follow! @place
			end
			morph "#{dom_id(@place, 'follow-button')}", render(FollowButtonComponent.new(followable: @place, user: current_user, type: @type))
		else
			show_login_modal
		end
	end

	private

	def show_login_modal
		morph '#modal', render(Modal::SignInComponent.new(
			text:   "Crie uma conta para seguir locais",
			opened: true))
	end

end
