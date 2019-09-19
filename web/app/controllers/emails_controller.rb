class EmailsController < ApplicationController
	before_action :authorize_admin

	def send_request_invite_confirmation
		@user = User.find params[:user_id]


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

end
