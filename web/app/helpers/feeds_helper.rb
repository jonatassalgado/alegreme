module FeedsHelper

	def favorited(event)
		unless current_user
			return false
		end
		current_user.favorited?(event, scope: ['favorite'])
	end

	# TODO Extrair daqui
	def filter_exist_in_ocurrences?(params, ocurrences)
		if params.any?(&method(:valid_json?))
			params.map { |filter| valid_json?(filter) ? JSON.parse(filter) : filter }.flatten.any? { |param| ocurrences.include?(param) }
		else
			params.include?(ocurrences)
		end
	end

	private

	# TODO Extrair daqui
	def valid_json?(json)
		JSON.parse(json)
		true
	rescue JSON::ParserError => e
		return false
	end
end
