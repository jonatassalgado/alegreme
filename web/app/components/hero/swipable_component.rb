class Hero::SwipableComponent < ViewComponent::Base

	def initialize(user:)
		@min_events_to_train       = 5
		@suggestion_hours_interval = 24
		@user                      = user
		@end_train_message         = show_end_message
		events_to_train_or_suggestions
		show_swipable?
	end


	private

	def show_end_message
		if @user
			@user.liked_event_ids.size >= @min_events_to_train && @user.swipable['events']['finished_at'].blank?
		else
			false
		end
	end

	def update_last_view_at
		@user.swipable.deep_merge!({
																 'events' => {
																	 'last_view_at' => DateTime.now
																 }
															 })
		@user.save
	end

	def show_swipable?
		if @user
			@show_swipable = (DateTime.now - @suggestion_hours_interval.hours) > @user.swipable.dig('events', 'hidden_at').to_datetime rescue true
			update_last_view_at if @show_swipable
		else
			@show_swipable = false
		end
	end

	def events_to_train_or_suggestions
		return unless @user

		@user.liked_or_disliked_events.reset
		if @user.swipable['events']['finished_at'].blank? && @user.liked_event_ids.size < @min_events_to_train
			@events_to_train = Event.not_ml_data.active.not_liked_or_disliked(@user).order_by_date.limit(2)
		else
			@events_suggestions = Event.not_ml_data.active.in_user_suggestions(@user).not_liked_or_disliked(@user).limit(2)
		end
	end

end