# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

class CheckLoggerTest < ActiveSupport::TestCase
  setup do
    @check = create(:check)
    @logger = CheckLogger.new(@check)
  end

  test "should create a pending CheckLog" do
    assert_difference -> { CheckLog.where(check: @check).count }, +1 do
      CheckLogger.new(@check)
    end

    assert last_log.pending?
  end

  test "should log a success raw result command" do
    result = SystemCommand::Result.new("command", 0, "the result", "")

    assert_no_difference -> { CheckLog.where(check: @check).count } do
      @logger.log :after_command, result
    end

    assert_equal "the result", @logger.check_log.raw_response
    assert_nil @logger.check_log.error
    assert_equal 0, @logger.check_log.exit_status
    assert @logger.check_log.pending?
  end

  test "should log a raw result command with an error" do
    result = SystemCommand::Result.new("command", 1, "optional stdout", "an error occured")
    @logger.log :after_command, result

    assert_equal "optional stdout", @logger.check_log.raw_response
    assert_equal "an error occured", @logger.check_log.error
    assert_equal 1, @logger.check_log.exit_status
    assert @logger.check_log.failed?
  end

  test "should log an error when there is not exit status" do
    result = SystemCommand::Result.new("command", nil, nil, "an error")
    @logger.log :after_command, result

    assert_nil @logger.check_log.raw_response
    assert_equal "an error", @logger.check_log.error
    assert_nil @logger.check_log.exit_status
    assert @logger.check_log.failed?
  end

  test "should log a successful parsed response" do
    response = OpenStruct.new(
      domain: "example.fr",
      extracted: "some data",
      valid?: true,
    )
    @logger.log :parsed_response, response

    assert_equal response.to_json, @logger.check_log.parsed_response
    assert_nil @logger.check_log.error
    assert @logger.check_log.succeed?
  end

  test "should log as failed a empty/error parsed response" do
    response = OpenStruct.new(
      domain: "example.fr",
      valid?: false,
    )
    @logger.log :parsed_response, response

    assert_equal response.to_json, @logger.check_log.parsed_response
    assert @logger.check_log.failed?
  end

  test "should log parser error with a backtrace" do
    @logger.log :parser_error, mock_exception

    assert_includes @logger.check_log.error, "my error occured"
    assert_includes @logger.check_log.error, "minitest.rb"
    assert @logger.check_log.failed?
  end

  test "should log standard error with a backtrace" do
    @logger.log :standard_error, mock_exception

    assert_includes @logger.check_log.error, "my error occured"
    assert_includes @logger.check_log.error, "minitest.rb"
    assert @logger.check_log.failed?
  end

  test "should log service error" do
    @logger.log :service_error, mock_exception

    assert_not_nil @logger.check_log.error
    assert @logger.check_log.failed?
  end

  private

  def last_log
    CheckLog.where(check: @check).last
  end

  def mock_exception
    exception = ArgumentError.new("my error occured")
    exception.set_backtrace(caller)
    exception
  end
end
