# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

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

  def after_sign_in_path_for(_resource)
    checks_path
  end

  def after_sign_up_path_for(_resource)
    checks_path
  end

  def after_sign_out_path_for(_resource)
    root_path
  end

  def user_not_authorized
    flash[:alert] = I18n.t("user_not_authorized", scope: :flashes)
    redirect_to(request.referrer || root_path)
  end

  def set_locale
    I18n.locale = current_user.try(:locale) \
      || request.env["rack.locale"].presence \
      || I18n.default_locale
  end

  def not_found
    fail ActionController::RoutingError, "Not Found"
  rescue StandardError
    render_404
  end

  def render_404
    render file: "#{Rails.root}/public/404.html", status: :not_found
  end
end
