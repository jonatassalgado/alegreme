class WelcomeController < ApplicationController
	before_action :verify_permissions, only: %i[index]


	layout 'welcome'

	def index
		@invites_count    = count_invites
		@events_count     = Rails.cache.fetch("welcome-events-count", expires_in: 1.day) { Event.active.length }
		@organizers_count = Rails.cache.fetch("welcome-organizers-count", expires_in: 1.day) { Organizer.count }
		@last_people      = User.select("features -> 'demographic' as demographic").order('created_at DESC').where("(features -> 'demographic' ->> 'name') IS NOT NULL AND (features -> 'demographic' ->> 'picture') IS NOT NULL").limit(15)
	end

	def invite
		@user = User.find_by_email(params[:email])

		if @user
			render json: {invitesCount: count_invites, name: @user.features.dig('demographic', 'name'), invitationAlreadyRequested: true}
		else
			if create_invite
				render json: {invitesCount: count_invites, invitationCreated: true, invitationAlreadyRequested: false}
			else
				render json: {invitationCreated: false, invitationAlreadyRequested: false}
			end
		end
	end


	private

	def verify_permissions
		if current_user&.has_permission_to_login?
			current_user.update_tracked_fields!(request)
			redirect_to feed_path
		end
	end

	def count_invites
		1226 + User.all.count
	end

	def create_invite
		user = User.new(email:    params[:email],
		                password: Devise.friendly_token[0, 20])

		user.features.deep_merge!({
				                          'demographic' => {
						                          'name'    => params[:name],
						                          'picture' => params[:picture],
						                          'beta'    => {
								                          'requested' => true,
								                          'activated' => false
						                          },
																			'social'   => {
																				'fbId'     => params[:fbId],
																				'googleId' => params[:googleId]
																			},
				                          }
		                          })
		user.save

		InviteMailer.with(user: user).send_request_invite_confirmation.deliver_later

		return user
	end


end
