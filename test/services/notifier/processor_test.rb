require "test_helper"

module Notifier
  class ProcessorTest < ActiveSupport::TestCase
    test "#process_expires_soon sends an email for checks expiring soon" do
      create_list(:notification, 3, :email, check: build(:check, :expires_next_week))
      create(:notification, :email, check: build(:check, :nil_dates))
      create(:notification, :email, check: build(:check, :inactive))

      processor = Processor.new
      assert_difference "ActionMailer::Base.deliveries.size", +3 do
        processor.process_expires_soon
      end

      last_email = ActionMailer::Base.deliveries.last
      assert_match "expires in 7 days", last_email.subject
    end

    test "#process_expires_soon respects the interval configuration between sends" do
      create_list(:notification, 3, :email, check: build(:check, :expires_next_week))
      test_interval_respected(:process_expires_soon, 3)
    end

    test "#process_recurrent_failures respects the interval configuration between sends" do
      create_list(:notification, 3, :email, check: build(:check, :last_runs_failed))
      test_interval_respected(:process_recurrent_failures, 3) do |configuration|
        configuration.expect(:consecutive_failures, 4)
      end
    end

    private

    # rubocop:disable Metrics/MethodLength
    def test_interval_respected(process_method, count_expected)
      configuration = Minitest::Mock.new
      count_expected.times do
        configuration.expect(:interval, 0.000001)
      end

      yield configuration if block_given?

      processor = Processor.new(configuration)

      mock = Minitest::Mock.new
      assert_stub = lambda { |actual_time|
        assert_equal 0.000001, actual_time
        mock
      }

      processor.stub :sleep, assert_stub do
        processor.public_send(process_method)
      end

      configuration.verify
      mock.verify
    end
    # rubocop:enable Metrics/MethodLength
  end
end
