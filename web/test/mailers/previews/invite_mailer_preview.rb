# Preview all emails at http://localhost:3000/rails/mailers/invite_mailer
class InviteMailerPreview < ActionMailer::Preview
	def send_request_invite_confirmation
		@user = User.find 2
		InviteMailer.with(user: @user).send_request_invite_confirmation
	end

	def send_invite_activation_link
		@user  = User.find 2
		@token = @user.send(:set_reset_password_token)

		InviteMailer.with(user: @user, token: @token).send_invite_activation_link
	end
end
