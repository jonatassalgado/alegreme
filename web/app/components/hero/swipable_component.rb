class Hero::SwipableComponent < ViewComponent::Base

	def initialize(user:)
		@user                      = user
		@min_events_to_train       = 5
		@suggestions_batch_size    = 3
		@suggestion_hours_interval = 12
		@suggestions_viewed        = get_suggestions_viewed
		@show_swipable             = show_swipable?
		events_to_train_or_suggestions
	end

	def render?
		show_swipable?
	end

	private

	def get_suggestions_viewed
		@user ? Rails.cache.fetch("#{@user.cache_key}/hero--swipable/suggestions_viewed", { expires_in: 1.hour, skip_nil: true, raw: true }) { 0 } : 0
	end

	def events_trained
		@user ? @user&.liked_event_ids&.size : 0
	end

	def show_end_message
		if @user
			events_trained >= @min_events_to_train && @user.swipable['events']['finished_at'].blank?
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
		return true unless @user
		show_swipable = (DateTime.now - @suggestion_hours_interval.hours) > @user.swipable.dig('events', 'hidden_at').to_datetime rescue true
		update_last_view_at if show_swipable
		show_swipable
	end

	def events_to_train_or_suggestions
		unless @user
			@events_to_train = Event.includes(:place, :categories).active.valid.where(categories: { theme_id: 1 }).limit(1)
			return
		end

		@user.liked_or_disliked_events.reset
		if @user.swipable['events']['finished_at'].blank? && events_trained < @min_events_to_train
			@events_to_train = Event.includes(:place, :categories).not_ml_data.active.valid.order_by_score.not_liked_or_disliked(@user).where(categories: { theme_id: 1 }).order_by_date.limit(1)
		else
			@events_suggestions = Event.includes(:place, :categories).not_ml_data.active.valid.in_user_suggestions(@user).not_liked_or_disliked(@user).limit(1)
		end
	end

	def current_stage
		return :train unless @user

		@user.reload

		if @user.swipable['events']['finished_at'].blank? && @events_to_train.present?
			:train
		elsif show_end_message
			:end_train_message
		elsif @suggestions_viewed.to_i < @suggestions_batch_size && @user.swipable['events']['finished_at'] && @events_suggestions.present?
			:suggestions
		elsif @suggestions_viewed.to_i >= @suggestions_batch_size || @events_suggestions.blank?
			:end_suggestions_message
		end
	end

end