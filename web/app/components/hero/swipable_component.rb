class Hero::SwipableComponent < ViewComponentReflex::Component

	def initialize(user:, events:)
		@user              = user
		@events            = events
		@end_train_message = true
		update_last_view_at
	end

	def update(args = {})
		@events            = events_to_train
		@end_train_message = @events.size > 3 ? true : false
	end

	def hide_end_message
		update_finished_at
		@end_train_message = false
	end

	private

	def update_finished_at
		@user.swipable.deep_merge!({
																 'events' => {
																	 'finished_at' => DateTime.now
																 }
															 })
		@user.save
	end

	def update_last_view_at
		@user.swipable.deep_merge!({
																 'events' => {
																	 'last_view_at' => DateTime.now
																 }
															 })
	end

	def events_to_train
		@user.liked_or_disliked_events.reset
		Event.active.not_liked_or_disliked(@user).order_by_score.limit(3)
	end

end