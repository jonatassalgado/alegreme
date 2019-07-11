# noinspection ALL
module EventServices
	class SimilarFetcher
		# class << self
		# 	# attr_accessor :user
		# end


		# @param [Event[]] similar_to
		# @param [Event[]] base
		def initialize(similar_to_events, base_events)
			@similar_to = similar_to_events
			@base       = base_events
			@responses  = {
					resources:   {},
					all_success: false
			}
		end

		def call(opts = {})
			@opts = opts

			fetch_similar_resources
			create_mixed_suggestions

			@responses
		end


		private

		def create_mixed_suggestions
			if @opts[:mixed_suggestions]
				# resources_quantity = calculate_quantity
				mixed_suggestions = []

				counter = 0
				limit   = @responses[:resources].keys.size

				until mixed_suggestions.size >= 15 || counter >= 10 do
					@responses[:resources].keys.each do |key|
						mixed_suggestions |= [@responses[:resources][key][:similar][counter]]
					end
					counter += 1
				end

				@responses[:mixed_suggestions] = mixed_suggestions.flatten.compact
			end
		end

		def fetch_similar_resources
			base_to_compare = @base.map { |event| [event.ml_data['stemmed'], event.id] }

			@similar_to.each do |event|
				event_to_search_similar_index = base_to_compare.find_index { |e| e[1] == event.id }
				params_to_compare             = {text: event_to_search_similar_index, base: Base64.encode64(base_to_compare.to_s)}

				similar_api       = URI("#{ENV["API_URL"]}:5000/event/similar")
				similar_api.query = URI.encode_www_form(params_to_compare)

				response = Net::HTTP.get_response(similar_api)
				success  = response.is_a?(Net::HTTPSuccess)
				data     = JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

				mount_response(data, event, success)
			end

			veirify_success
		end

		def mount_response(data, event, success)
			@responses[:resources][event.id] = {success: success, similar: data}
		end

		def veirify_success
			@responses[:all_success] = @responses[:resources].all? { |resource| resource[1][:success] }
		end

		def calculate_quantity
			if @responses[:resources].blank?
				return 8
			end

			quantity = @opts[:mixed_suggestions_qty] || 16
			quantity / @responses[:resources].keys.size
		end

	end
end
