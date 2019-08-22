class ApplicationController < ActionController::Base
  include AuthorizationHelper

  etag {current_or_guest_user.try :id}

  # Sentry
  if Rails.env.production?
    before_action :set_raven_context
  end


  def authorize_user
    redirect_to root_path, notice: 'Acesso somente para usuários logados' unless current_user
  end

  def authorize_admin
    redirect_to root_path, notice: 'Acesso somente para administradores' unless current_user && current_user.admin?
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  private

  # Sentry
  def set_raven_context
    Raven.user_context(id: session[current_user.try(:id)]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end


end
