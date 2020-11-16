module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :session_id #, :uuid

    def connect
      # if !env['warden'].user
      # 	self.uuid = SecureRandom.urlsafe_base64
      # else
      # 	self.current_user = find_verified_user
      # end
      self.current_user = env["warden"].user
      self.session_id   = request.session.id
      reject_unauthorized_connection unless self.current_user || self.session_id
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
