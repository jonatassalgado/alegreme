class UserChannel < ApplicationCable::Channel
	include CableReady::Broadcaster

	def subscribed
		stream_for current_user
	end

	def unsubscribed
		# Any cleanup needed when channel is unsubscribed
	end

	def like(data)
		opts          = JSON.parse(data['body']['data-cable-ready-opts'], {:symbolize_names => true})
		resource_id   = data['body']['data-cable-ready-resource-id'].to_i
		resource_type = data['body']['data-cable-ready-resource-type']
		action        = data['body']['data-cable-ready-action']
		resource      = resource_type.classify.constantize.find resource_id
		like          = current_user.likes.find_by_event_id(resource.id)

		if action == 'like'
			if like&.sentiment == 'negative'
				like.update(sentiment: :positive)
			elsif like&.sentiment == 'positive'
				current_user.unlike! resource
			else
				current_user.like!(resource)
			end
		elsif action == 'dislike'
			if like&.sentiment == 'positive'
				like.update(sentiment: :negative)
			elsif like&.sentiment == 'negative'
				current_user.unlike! resource
			else
				current_user.dislike!(resource)
			end
		end

		if opts[:training]
			cable_ready[UserChannel].add_css_class(
					selector: dom_id(resource),
					name:     "hidden"
			)
			cable_ready[UserChannel].dispatch_event(
					name:     "swipable#event->trained",
					selector: "#swipable",
					detail:   {eventsLiked: current_user.liked_events.size}
			)
		else
			cable_ready[UserChannel].morph(
					selector: dom_id(resource),
					html:     ApplicationController.render(partial: opts[:partial],
					                                       locals:  {
							                                       event: resource,
							                                       user:  current_user
					                                       })
			)
		end

		cable_ready.broadcast_to(current_user, UserChannel)
	end


	def hero
		@selected_tab     = 'suggestions'
		@train_events     = Event.active.not_liked_or_disliked(current_user).order_by_score.limit(12)
		@suggested_events = current_user ? Event.not_ml_data.active.not_liked_or_disliked(current_user).in_user_suggestions(current_user).includes(:place).order_by_date : Event.none

		cable_ready[UserChannel].morph(
				selector: "#hero",
				html:     ApplicationController.render(partial: 'feeds/hero',
				                                       locals:  {
						                                       user:             current_user,
						                                       train_events:     @train_events,
						                                       selected_tab:     @selected_tab,
						                                       suggested_events: @suggested_events
				                                       })
		)

		cable_ready.broadcast_to(current_user, UserChannel)
	end

	def tab(data)
		@tab              = data['body']['data-cable-ready-current-tab']
		@suggested_events = Event.not_ml_data.active.not_liked_or_disliked(current_user).in_user_suggestions(current_user).includes(:place).order_by_date

		cable_ready[UserChannel].morph(
				selector: '#feed-tabs',
				html:     ApplicationController.render(partial: 'feeds/tabs',
				                                       locals:  {
						                                       user:             current_user,
						                                       selected_tab:     @tab,
						                                       suggested_events: @suggested_events
				                                       })
		)

		cable_ready.broadcast_to(current_user, UserChannel)
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
