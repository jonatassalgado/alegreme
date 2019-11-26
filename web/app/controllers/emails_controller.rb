class EmailsController < ApplicationController
	before_action :authorize_admin

	def send_request_invite_confirmation
		@user = User.friendly.find params[:user_id]

		respond_to do |format|
			if @user.email.present?
				InviteMailer.with(user: @user).send_request_invite_confirmation.deliver_later

				format.html { redirect_to users_path, notice: 'Email enviado com sucesso.' }
				format.json { render :'users/index', status: :ok, location: @user }
			else
				format.html { render :'users/index' }
				format.json { render json: @users.errors, status: :unprocessable_entity }
			end
		end
	end


	def send_invite_activation_link
		@user = User.friendly.find params[:user_id]

		@user.features.deep_merge!({
				                           'demographic' => {
						                           'beta' => {
								                           'activated' => true
						                           }
				                           }
		                           })

		@token = @user.send(:set_reset_password_token)

		respond_to do |format|
			if @user.save && @user.reset_password_token? && @user.email.present?
				InviteMailer.with(user: @user, token: @token).send_invite_activation_link.deliver_later

				format.html { redirect_to users_path, notice: 'Email enviado com sucesso.' }
				format.json { render :'users/index', status: :ok, location: @user }
			else
				format.html { render :'users/index' }
				format.json { render json: @users.errors, status: :unprocessable_entity }
			end
		end
	end

end
