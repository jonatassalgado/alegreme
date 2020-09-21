module Sheets
	class FriendshipsController < ApplicationController

		def edit
			@user   = current_user
			@friend = User.find params[:friend_id]
			render layout: false
		end

	end
end
