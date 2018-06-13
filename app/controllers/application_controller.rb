class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_devise_parameters, if: :devise_controller?
  before_action :set_locale

  protected

  def configure_devise_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:tos_accepted, :locale])
    devise_parameter_sanitizer.permit(:account_update, keys: [:notifications_enabled, :locale])
  end

  def user_not_authorized
    flash[:alert] = I18n.t("user_not_authorized", scope: :flashes)
    redirect_to(request.referrer || root_path)
  end

  def set_locale
    I18n.locale = current_user.try(:locale) || I18n.default_locale
  end
end
