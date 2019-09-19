# Preview all emails at http://localhost:3000/rails/mailers/invite_mailer
class InviteMailerPreview < ActionMailer::Preview
	def send_request_invite_confirmation
		@user = User.find params[:user_id]
		InviteMailer.with(user: @user).send_request_invite_confirmation
	end
end
