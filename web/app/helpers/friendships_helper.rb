module FriendshipsHelper

	def status_to_human_readable(status)
		case status
		when 'requested'
			'Aceitar'
		when 'accepted'
			'Aceito'
		end
	end

end