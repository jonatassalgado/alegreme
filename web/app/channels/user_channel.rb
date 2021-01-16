class UserChannel < ApplicationCable::Channel
	# include CableReady::Broadcaster

	def subscribed
		stream_for current_user
	end

	def unsubscribed
		# Any cleanup needed when channel is unsubscribed
	end

	def follow(data)
		followable_id   = data['body']['data-cable-ready-followable-id'].to_i
		followable_type = data['body']['data-cable-ready-followable-type']
		follow_action   = data['body']['data-cable-ready-follow-action']
		followable      = followable_type.classify.constantize.find followable_id

		case follow_action
		when 'follow'
			current_user.follow! followable
		when 'unfollow'
			current_user.unfollow! followable
		else
			logger.error "Unable to process follow_action: #{follow_action}"
		end

		cable_ready[UserChannel].morph(
				selector: dom_id(followable),
				html:     ApplicationController.render(partial: 'components/follow/follow_button',
				                                       locals:  {
						                                       identifier: followable.try(:slug),
						                                       user:       current_user,
						                                       followable: followable
				                                       }
				)
		)

		cable_ready.broadcast_to(current_user, UserChannel)
	end


	def friendship(data)
		friendship_action = data['body']['data-cable-ready-friendship-action']
		partial           = data['body']['data-cable-ready-partial']
		user              = User.find data['body']['data-cable-ready-user-id'].to_i
		friend            = User.find data['body']['data-cable-ready-friend-id'].to_i

		if Friendship.create_between_users(user, friend, friendship_action)
			if partial == 'button'
				cable_ready[UserChannel].morph(
						selector: dom_id(friend, :friendship_button),
						html:     ApplicationController.render(partial: 'friendships/friendship_button',
						                                       locals:  {
								                                       user:   user,
								                                       friend: friend
						                                       }
						)
				)
			else
				cable_ready[UserChannel].morph(
						selector: dom_id(user, :friendship_request),
						html:     ApplicationController.render(partial: 'friendships/friendship_request',
						                                       locals:  {
								                                       friend: user,
								                                       user:   friend
						                                       }
						)
				)
			end
		else

		end


		cable_ready.broadcast_to(current_user, UserChannel)
	end


end
