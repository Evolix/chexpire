# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class NotificationsMailer < ApplicationMailer
  helper :application

  before_action except: :recurrent_failures do
    @check_notification = params.fetch(:check_notification)
    @check = @check_notification.check
    @notification = @check_notification.notification
  end

  def domain_expires_soon
    I18n.with_locale params&.fetch(:locale) { @check.user.locale } do
      subject = t(".subject", domain: @check.domain, count: @check.domain_expires_in_days)
      mail subject: subject, to: @notification.recipient
    end
  end

  def ssl_expires_soon
    I18n.with_locale params&.fetch(:locale) { @check.user.locale } do
      subject = t(".subject", domain: @check.domain, count: @check.domain_expires_in_days)
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
