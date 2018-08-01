# Preview all emails at http://localhost:3000/rails/mailers/notifications_mailer
class NotificationsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notifications_mailer/domain_expires_soon
  def domain_expires_soon
    check = Check.domain.first
    NotificationsMailer.with(notification: check.notifications.first).domain_expires_soon
  end

  # Preview this email at http://localhost:3000/rails/mailers/notifications_mailer/ssl_expires_soon
  def ssl_expires_soon
    check = Check.ssl.first
    NotificationsMailer.with(notification: check.notifications.first).ssl_expires_soon
  end

  # Preview this email at http://localhost:3000/rails/mailers/notifications_mailer/recurrent_failures
  def recurrent_failures
    user = User.first
    checks = Check.consecutive_failures(2).where(user: user)
    NotificationsMailer.recurrent_failures(user, checks)
  end
end
