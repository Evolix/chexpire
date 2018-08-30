# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

module Notifier
  module Channels
    class BaseTest < ActiveSupport::TestCase
      setup do
        class FakeChannel < Base
          def supports?(check_notification)
            check_notification.notification.interval < 1_000
          end

          def domain_notify_expires_soon(*); end
        end

        @channel = FakeChannel.new
      end

      test "#notify change the status of the notification" do
        check_notification = create(:check_notification)

        @channel.notify(check_notification)

        check_notification.reload

        assert check_notification.ongoing?
        assert_just_now check_notification.sent_at
      end

      test "#notify raises an exception for a non supported check kind" do
        check_notification = Minitest::Mock.new
        check_notification.expect :ongoing!, true
        check_notification.expect :notification, OpenStruct.new(interval: 10)

        check = Minitest::Mock.new
        check.expect(:kind, :invalid_kind)
        check.expect(:kind, :invalid_kind) # twice (second call for exception message)

        check_notification.expect :check, check
        check_notification.expect :check, check

        assert_raises ArgumentError do
          @channel.notify(check_notification)
        end

        check.verify
        check_notification.verify
      end

      test "#notify does nothing when channel doesn't support a notification whatever the reason" do
        check_notification = create(:check_notification, notification: build(:notification, interval: 10_000))

        @channel.notify(check_notification)

        check_notification.reload

        assert check_notification.pending?
        assert_nil check_notification.sent_at
      end
    end
  end
end
