module ApplicationCable
	class Connection < ActionCable::Connection::Base
		identified_by :current_user, :uuid

		def connect
			if !env['warden'].user
				self.uuid = SecureRandom.urlsafe_base64
			else
				self.current_user = find_verified_user
			end
		end

		protected

		def find_verified_user
			if (current_user = env["warden"].user)
				current_user
			else
				reject_unauthorized_connection
			end
		end
	end
end
