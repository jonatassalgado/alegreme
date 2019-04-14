class ApplicationController < ActionController::Base


  def authorize_user
    redirect_to root_path, notice: 'Acesso somente logado' unless current_user
  end

  def authorize_admin
    redirect_to root_path, notice: 'Acesso somente admins' unless current_user.admin?
  end

end
