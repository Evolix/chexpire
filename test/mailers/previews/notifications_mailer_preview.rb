# Preview all emails at http://localhost:3000/rails/mailers/notifications_mailer
class NotificationsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notifications_mailer/domain_expires_soon
  def domain_expires_soon
    NotificationsMailer.with(notification: Notification.first).domain_expires_soon
  end

  # Preview this email at http://localhost:3000/rails/mailers/notifications_mailer/domain_recurrent_failures
  def domain_recurrent_failures
    check = Check.where("last_run_at != last_success_at").limit(1).first
    NotificationsMailer.with(notification: check.notifications.first).domain_recurrent_failures
  end
end
