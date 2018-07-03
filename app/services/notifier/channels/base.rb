module Notifier
  module Channels
    class Base
      def notify(reason, notification) # rubocop:disable Metrics/MethodLength
        return unless supports?(reason, notification)

        notification.ongoing!

        case [notification.check.kind.to_sym, reason]
        when [:domain, :expires_soon]
          domain_notify_expires_soon(notification)
        when [:domain, :recurrent_failures]
          domain_notify_recurrent_failures(notification)
        when [:ssl, :expires_soon]
          ssl_notify_expires_soon(notification)
        when [:ssl, :recurrent_failures]
          ssl_notify_recurrent_failures(notification)
        else
          fail ArgumentError,
            "Invalid notification reason `#{reason}` for check kind `#{notification.check.kind}`."
        end
      end

      private

      # :nocov:
      def supports?(_reason, _notification)
        fail NotImplementedError,
          "#{self.class.name} channel did not implemented method #{__callee__}"
      end

      %i[
        domain_notify_expires_soon
        domain_notify_recurrent_failures
        ssl_notify_expires_soon
        ssl_notify_recurrent_failures
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
