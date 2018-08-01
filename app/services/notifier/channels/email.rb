# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module Notifier
  module Channels
    class Email < Base
      # Error notifications - all checks grouped by user
      def notify_recurrent_failures(user, checks)
        NotificationsMailer.recurrent_failures(user, checks).deliver_now
      end

      protected

      def supports?(_notification)
        true
      end

      # Expiration notifications
      def domain_notify_expires_soon(notification)
        NotificationsMailer.with(notification: notification).domain_expires_soon.deliver_now
      end

      def ssl_notify_expires_soon(notification)
        NotificationsMailer.with(notification: notification).ssl_expires_soon.deliver_now
      end
    end
  end
end
