# Preview all emails at http://localhost:3000/rails/mailers/notifications_mailer
class NotificationsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notifications_mailer/domain_expires_soon
  def domain_expires_soon
    check = Check.domain.first
    NotificationsMailer.with(notification: check.notifications.first).domain_expires_soon
  end

  # Preview this email at http://localhost:3000/rails/mailers/notifications_mailer/domain_recurrent_failures
  def domain_recurrent_failures
    check = Check.domain.where("last_run_at != last_success_at").first
    NotificationsMailer.with(notification: check.notifications.first).domain_recurrent_failures
  end

  # Preview this email at http://localhost:3000/rails/mailers/notifications_mailer/ssl_expires_soon
  def ssl_expires_soon
    check = Check.ssl.first
    NotificationsMailer.with(notification: check.notifications.first).ssl_expires_soon
  end

  # Preview this email at http://localhost:3000/rails/mailers/notifications_mailer/ssl_recurrent_failures
  def ssl_recurrent_failures
    check = Check.ssl.where("last_run_at != last_success_at").first
    NotificationsMailer.with(notification: check.notifications.first).ssl_recurrent_failures
  end
end
