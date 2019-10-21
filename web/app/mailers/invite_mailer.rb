class InviteMailer < ApplicationMailer
	default :from => 'Alegreme', :reply_to => 'oi@alegreme.com'

	# send a signup email to the user, pass in the user object that   contains the user's email address
	def send_request_invite_confirmation
		@user = params[:user]
		mail(:to      => @user.email,
		     :subject => 'Recebemos sua solicitação de convite para o Alegreme')
	end

	def send_invite_activation_link
		@user      = params[:user]
		@token     = params[:token]
		@plataform = @user.social_plataform_id

		mail(:to      => @user.email,
		     :subject => 'Seu convite para o Alegreme chegou!')
	end
end
