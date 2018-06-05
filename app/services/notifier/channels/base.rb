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

      # domain notifications
      def domain_notify_expires_soon(_notification)
        fail NotImplementedError,
          "Channel #{self.class.name} does not implement #{__callee__}"
      end

      def domain_notify_recurrent_failures(_notification)
        fail NotImplementedError,
          "Channel #{self.class.name} does not implement #{__callee__}"
      end
      # :nocov:
    end
  end
end
