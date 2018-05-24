class ApplicationController < ActionController::Base
  before_action :configure_devise_parameters, if: :devise_controller?

  protected

  def configure_devise_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:tos_accepted])
    devise_parameter_sanitizer.permit(:account_update, keys: [:notifications_enabled])
  end
end
