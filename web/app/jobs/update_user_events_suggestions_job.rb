class UpdateUserEventsSuggestionsJob < ApplicationJob
	queue_as :default

	rescue_from(Exception) do |exception|
		logger.debug exception
	end

	def perform(user_id)
		user          = User.find user_id
		active_events = Event.active
		saved_events  = user.saved_events

		similar_events = EventServices::SimilarFetcher.new(saved_events, active_events).call(mixed_suggestions: true)

		user.suggestions['events'] = similar_events[:mixed_suggestions]
		user.save
	end
end
