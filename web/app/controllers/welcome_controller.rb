class WelcomeController < ApplicationController

	layout 'welcome'

	def index
		@invites_count    = count_invites
		@events_count     = Rails.cache.fetch("welcome-events-count", expires_in: 1.day) { Event.active.size }
		@organizers_count = Rails.cache.fetch("welcome-organizers-count", expires_in: 1.day) { Organizer.count }
		@last_people      = User.select("features -> 'demographic' as demographic").order('created_at DESC').where("(features -> 'demographic' ->> 'name') IS NOT NULL").limit(10)
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

	def privacy
	end

	def terms
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
