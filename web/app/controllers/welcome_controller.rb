class WelcomeController < ApplicationController

	layout 'welcome'

	def index
		@invites_count = count_invites
		@last_people   = User.select("features -> 'demographic' as demographic").order('created_at DESC').where("(features -> 'demographic' ->> 'name') IS NOT NULL").limit(10)
	end

	def invite
		@user = User.find_by_email(params[:email])

		if @user
			render json: {invitesCount: count_invites, name: @user.features['demographic']['name'], invitationAlreadyRequested: true}
		else
			if create_invite
				render json: {invitesCount: count_invites, invitationCreated: true, invitationAlreadyRequested: false}
			else
				render json: {invitationCreated: false, invitationAlreadyRequested: false}
			end
		end
	end

	private

	def count_invites
		624 + User.all.count
	end

	def create_invite
		user = User.new(email:    params[:email],
		                password: Devise.friendly_token[0, 20])

		user.features.deep_merge!({
				                         'demographic' => {
						                         'name'    => params[:name],
						                         'picture' => params[:picture]
				                         }
		                         })
		user.save
	end


end

