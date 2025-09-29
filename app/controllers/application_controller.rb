class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(resource)
    resource.admin? ? admin_users_path : portfolios_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username ])
  end

  def require_confirmed_user!
    unless current_user&.confirmed?
      redirect_to root_path, alert: "You must confirm your email first."
    end
  end

  def require_approved_trader!
    unless current_user&.trader?
      redirect_to root_path, alert: "Your account must be approved before trading."
    end
  end
end
