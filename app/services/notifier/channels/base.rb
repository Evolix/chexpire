# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module Notifier
  module Channels
    class Base
      def notify(notification) # rubocop:disable Metrics/MethodLength
        return unless supports?(notification)

        notification.ongoing!

        case notification.check.kind.to_sym
        when :domain
          domain_notify_expires_soon(notification)
        when :ssl
          ssl_notify_expires_soon(notification)
        else
          fail ArgumentError,
            "Invalid notification for check kind `#{notification.check.kind}`."
        end
      end

      private

      # :nocov:
      def supports?(_notification)
        fail NotImplementedError,
          "#{self.class.name} channel did not implemented method #{__callee__}"
      end

      %i[
        domain_notify_expires_soon
        ssl_notify_expires_soon
      ].each do |method|
        define_method(method) do
          fail NotImplementedError,
            "Channel #{self.class.name} does not implement method #{method}."
        end
      end
      # :nocov:
    end
  end
end
