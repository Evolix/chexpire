# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"
# require "system_command"

class SystemCommandTest < ActiveSupport::TestCase
  test "should execute and log a command" do
    mock_logger = Minitest::Mock.new
    expected_cmd = 'whois "example.org"'

    expected_result = SystemCommand::Result.new(
      expected_cmd,
      0,
      "my result",
      "",
    )

    mock_logger.expect(:log, nil, [:before_command, expected_cmd])
    mock_logger.expect(:log, nil, [:after_command, expected_result])

    command = SystemCommand.new("whois", "example.org", logger: mock_logger)
    assert_equal expected_cmd, command.syscmd

    command.stub(:call, expected_result) do
      assert_equal expected_result, command.execute
    end

    mock_logger.verify
  end
end
