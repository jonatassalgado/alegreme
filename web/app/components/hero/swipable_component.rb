class Hero::SwipableComponent < ViewComponentReflex::Component

	def initialize(user:)
		@max_events_to_show        = 3
		@min_events_to_train       = 5
		@suggestion_hours_interval = 24
		@user                      = user
		@end_train_message         = false
		events_to_train_or_suggestions
		show_swipable?
	end

	def update
		events_to_train_or_suggestions
		@end_train_message = @user.liked_event_ids.size >= @min_events_to_train ? true : false
	end

	def hide_end_message
		update_finished_at
		@end_train_message = false
	end

	def hidden_swipable
		update_hidden_at
		show_swipable?
	end

	private

	def show_swipable?
		@show_swipable = (DateTime.now - 	@suggestion_hours_interval.hours) > @user.swipable.dig('events', 'hidden_at').to_datetime rescue true
		update_last_view_at if @show_swipable
	end

	def update_finished_at
		@user.swipable.deep_merge!({
																 'events' => {
																	 'finished_at' => DateTime.now
																 }
															 })
		@user.save
	end

	def update_hidden_at
		@user.swipable.deep_merge!({
																 'events' => {
																	 'hidden_at' => DateTime.now
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
		@user.save
	end

	def events_to_train_or_suggestions
		@user.liked_or_disliked_events.reset
		if @user.swipable['events']['finished_at'].blank? && @user.liked_event_ids.size < @min_events_to_train
			@events_to_train = Event.not_ml_data.active.not_liked_or_disliked(@user).order_by_date.limit(3)
		else
			@events_suggestions = Event.not_ml_data.active.in_user_suggestions(@user).not_liked_or_disliked(@user).limit(3)
		end
	end

end