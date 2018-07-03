class NotificationsMailer < ApplicationMailer
  helper :application

  before_action do
    @notification = params.fetch(:notification)
    @check = @notification.check
  end

  default to: -> { @notification.recipient }

  def domain_expires_soon
    @expire_in_days = Integer(@check.domain_expires_at.to_date - Date.today)

    subject = t(".subject", domain: @check.domain, count: @expire_in_days)
    mail subject: subject
  end

  def domain_recurrent_failures
    subject = t(".subject", domain: @check.domain)
    mail subject: subject
  end

  def ssl_expires_soon
    @expire_in_days = Integer(@check.domain_expires_at.to_date - Date.today)

    subject = t(".subject", domain: @check.domain, count: @expire_in_days)
    mail subject: subject
  end

  def ssl_recurrent_failures
    subject = t(".subject", domain: @check.domain)
    mail subject: subject
  end
end
