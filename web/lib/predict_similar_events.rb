module PredictSimilarEvents
	class << self
		def predict(event)
			active_events   = Event.active.where("id != ? AND (ml_data ->> 'stemmed') IS NOT NULL", event.id)
			base_to_compare = active_events.map { |other_event| [other_event.ml_data['stemmed'], other_event.id] }.unshift([event.ml_data['stemmed'], event.id]).to_json

			similar_params   = { 'text' => 0, 'base' => base_to_compare }
			similar_uri      = URI("#{ENV["API_URL"]}:5000/event/similar")
			similar_response = Net::HTTP.post_form(similar_uri, similar_params)
			response_success = similar_response.is_a?(Net::HTTPSuccess)
			similar_data     = response_success ? JSON.parse(similar_response.body) : []

			if response_success
				event.similar_data = similar_data
				event.save!
			end
		end
	end
end