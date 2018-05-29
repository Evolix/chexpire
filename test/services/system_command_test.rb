require "test_helper"
require "system_command"

class SystemCommandTest < ActiveSupport::TestCase
  test "should execute and log a command" do
    mock_logger = Minitest::Mock.new
    expected = 'whois "example.org"'

    mock_logger.expect(:log, nil, [:before_command, expected])
    mock_logger.expect(:log, nil, [:after_command, "my result"])

    command = SystemCommand.new("whois", "example.org", logger: mock_logger)
    assert_equal expected, command.syscmd

    command.stub(:`, "my result") do
      assert_equal "my result", command.execute
    end

    mock_logger.verify
  end
end
