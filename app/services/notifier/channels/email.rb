module Notifier
  module Channels
    class Email < Base
      REASONS = %i[expires_soon recurrent_failures].freeze

      protected

      def supports?(reason, _notification)
        REASONS.include?(reason)
      end

      def domain_notify_expires_soon(notification)
        NotificationsMailer.with(notification: notification).domain_expires_soon.deliver_now
      end

      def domain_notify_recurrent_failures(notification)
        NotificationsMailer.with(notification: notification).domain_recurrent_failures.deliver_now
      end

      def ssl_notify_expires_soon(notification)
        NotificationsMailer.with(notification: notification).ssl_expires_soon.deliver_now
      end

      def ssl_notify_recurrent_failures(notification)
        NotificationsMailer.with(notification: notification).ssl_recurrent_failures.deliver_now
      end
    end
  end
end
