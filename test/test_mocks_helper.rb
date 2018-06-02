require "system_command"

module TestMocksHelper
  # rubocop:disable Metrics/MethodLength
  def mock_system_command(program, args, exit_status: 0, stdout: "", stderr: "")
    syscmd = "#{program} #{Array.wrap(args).join(' ')}"
    result = SystemCommandResult.new(syscmd, exit_status, stdout, stderr)

    mock = Minitest::Mock.new
    mock.expect :execute, result

    fussy = lambda { |actual_program, actual_args, _logger|
      assert_equal program, actual_program,
       "SystemCommand was not initialized with the expected program name"

      assert_equal args, actual_args,
       "SystemCommand was not initialized with the expected arguments"

      mock
    }

    SystemCommand.stub :new, fussy do
      yield
    end

    mock.verify
  end
  # rubocop:enable Metrics/MethodLength
end
