class UpdateUserEventsSuggestionsJob < ApplicationJob
	queue_as :default

	rescue_from(Exception) do |exception|
		logger.debug exception
	end

	def perform(user_id)
		user          = User.find user_id
		active_events = Event.active
		liked_events  = user.liked_events.order("likes.created_at DESC").limit(10)

		similar_events = EventServices::SimilarFetcher.new(liked_events, active_events).call(mixed_suggestions: true)

		user.suggestions['events'] = similar_events[:mixed_suggestions]
		user.save
	end
end
