# frozen_string_literal: true

class FriendshipReflex < ApplicationReflex

	def friendship
		action = element['data-friendship-action']
		user   = User.find(element['data-user-id'])
		friend = User.find(element['data-friend-id'])

		if Friendship.create_between_users(user, friend, action)
			@friend = friend
			@sheet  = true if action == 'cancel'
			# morph dom_id(friend, :sheets_friendships_edit_action), render(
			# 		partial: 'sheets/friendships/edit',
			# 		locals:  {
			# 				user:   user,
			# 				friend: friend,
			# 				status: 'cancelled'
			# 		}
			# )
			#
			# morph dom_id(friend, :friendship_button), render(
			# 		partial: 'friendships/friendship_button',
			# 		locals:  {
			# 				user:   user,
			# 				friend: friend
			# 		}
			# )
			#
			# if friendship_action == 'cancel'
			# 	cable_ready[UserChannel].add_css_class(
			# 			selector: dom_id(friend, :friendships_accepted),
			# 			name:     "hidden"
			# 	)
			# 	cable_ready.broadcast_to(current_user, UserChannel)
			# end
		else
			@sheet = false
		end

	end

end
