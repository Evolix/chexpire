require "test_helper"

module Notifier
  class ProcessorTest < ActiveSupport::TestCase

    private

    # rubocop:disable Metrics/MethodLength
    def test_interval_respected(process_method, count_expected)
      configuration = Minitest::Mock.new
      count_expected.times do
        configuration.expect(:interval, 0.000001)
      end
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
