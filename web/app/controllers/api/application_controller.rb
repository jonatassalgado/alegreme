module Api
	class ApplicationController < ::ApplicationController
		skip_before_action :verify_authenticity_token
		include DeviseTokenAuth::Concerns::SetUserByToken

		# before_action :log_headers

		private

		def log_headers
			logger.debug "uid: #{request.headers['uid']}"
			logger.debug "client: #{request.headers['client']}"
			logger.debug "access-token: #{request.headers['access-token']}"
		end

	end
end