class NotificationsMailer < ApplicationMailer
  helper :application

  before_action except: :recurrent_failures do
    @notification = params.fetch(:notification)
    @check = @notification.check
  end

  def domain_expires_soon
    @expire_in_days = Integer(@check.domain_expires_at.to_date - Date.today)

    I18n.with_locale params&.fetch(:locale) { @check.user.locale } do
      subject = t(".subject", domain: @check.domain, count: @expire_in_days)
      mail subject: subject, to: @notification.recipient
    end
  end

  def ssl_expires_soon
    @expire_in_days = Integer(@check.domain_expires_at.to_date - Date.today)

    I18n.with_locale params&.fetch(:locale) { @check.user.locale } do
      subject = t(".subject", domain: @check.domain, count: @expire_in_days)
      mail subject: subject, to: @notification.recipient
    end
  end

  def recurrent_failures(user, checks)
    @checks = checks

    # params generally not set, except for preview mailer
    params_locale = (params[:locale] if params.present?)

    I18n.with_locale params_locale || user.locale do
      subject = t(".subject", count: checks.count, domain: checks.first.domain)
      mail subject: subject, to: user.email
    end
  end
end
