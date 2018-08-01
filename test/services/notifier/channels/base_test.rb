# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

module Notifier
  module Channels
    class BaseTest < ActiveSupport::TestCase
      setup do
        class FakeChannel < Base
          def supports?(notification)
            notification.interval < 1_000
          end

          def domain_notify_expires_soon(*); end
        end

        @channel = FakeChannel.new
      end

      test "#notify change the status of the notification" do
        notification = create(:notification)

        @channel.notify(notification)

        notification.reload

        assert notification.ongoing?
        assert_just_now notification.sent_at
      end

      test "#notify raises an exception for a non supported check kind" do
        notification = Minitest::Mock.new
        notification.expect :ongoing!, true
        notification.expect :interval, 10

        check = Minitest::Mock.new
        check.expect(:kind, :invalid_kind)
        check.expect(:kind, :invalid_kind) # twice (second call for exception message)

        notification.expect :check, check
        notification.expect :check, check

        assert_raises ArgumentError do
          @channel.notify(notification)
        end

        check.verify
        notification.verify
      end

      test "#notify does nothing when channel doesn't support a notification whatever the reason" do
        notification = create(:notification, interval: 10_000)

        @channel.notify(notification)

        notification.reload

        assert notification.pending?
        assert_nil notification.sent_at
      end
    end
  end
end
