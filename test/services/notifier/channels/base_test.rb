require "test_helper"

module Notifier
  module Channels
    class BaseTest < ActiveSupport::TestCase
      setup do
        class FakeChannel < Base
          def supports?(reason, _notification)
            reason != :unsupported
          end

          def domain_notify_expires_soon(*); end
        end

        @channel = FakeChannel.new
      end

      test "#notify change the status of the notification" do
        notification = create(:notification)

        @channel.notify(:expires_soon, notification)

        notification.reload

        assert notification.ongoing?
        assert_just_now notification.sent_at
      end

      test "#notify raises an exception for a invalid reason" do
        notification = build(:notification)

        assert_raises ArgumentError do
          @channel.notify(:unknown, notification)
        end
      end

      test "#notify does nothing when channel does not support a reason" do
        notification = create(:notification)

        @channel.notify(:unsupported, notification)

        notification.reload

        assert notification.pending?
        assert_nil notification.sent_at
      end
    end
  end
end
