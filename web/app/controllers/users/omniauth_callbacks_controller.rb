class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    login_user
  end

  def facebook
    login_user
  end

  private

  def login_user
    @user = User.from_omniauth(request.env['omniauth.auth'], nil, {})
    # @user = User.from_omniauth(request.env['omniauth.auth'], guest_user, params)

    if @user && @user.persisted?
      flash.now[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      #if @user&.has_permission_to_login?
        sign_in_and_redirect @user, event: :authentication
      #else
      #  redirect_to root_url, notice: "Seu convite ainda não foi ativado."
      #end
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except(:extra) # Removing extra as it can overflow some session stores
      logger.debug "Something went wrong with Omniauth Provider -> user not returned from omniauth -> #{request.env['omniauth.auth']}"
      redirect_to new_user_registration_path, alert: @user.errors.full_messages.join("\n")
    end
  end
end
