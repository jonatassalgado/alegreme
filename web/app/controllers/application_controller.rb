class ApplicationController < ActionController::Base
  include AuthorizationHelper

  def authorize_user
    redirect_to root_path, notice: 'Acesso somente para usuários logados' unless current_user
  end

  def authorize_admin
    redirect_to root_path, notice: 'Acesso somente para administradores' unless current_user && current_user.admin?
  end


end
