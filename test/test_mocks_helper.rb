# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module TestMocksHelper
  # rubocop:disable Metrics/MethodLength
  def mock_system_command(program, args, exit_status: 0, stdout: "", stderr: "")
    syscmd = "#{program} #{Array.wrap(args).join(' ')}"
    result = SystemCommand::Result.new(syscmd, exit_status, stdout, stderr)

    mock = Minitest::Mock.new
    mock.expect :execute, result

    assert_stub = lambda { |actual_program, actual_args, _logger|
      assert_equal program, actual_program,
       "SystemCommand was not initialized with the expected program name"

      assert_equal args, actual_args,
       "SystemCommand was not initialized with the expected arguments"

      mock
    }

    SystemCommand.stub :new, assert_stub do
      yield
    end

    mock.verify
  end
  # rubocop:enable Metrics/MethodLength
end
