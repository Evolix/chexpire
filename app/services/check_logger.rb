class CheckLogger
  attr_reader :check_log

  def initialize(check)
    @check_log = CheckLog.create!(check: check, status: :pending)
  end

  def log(event, message)
    case event
    when :after_command
      log_command_result(message)
    when :parsed_response
      log_parsed_response(message)
    when :parser_error, :service_error
      log_error(message)
    end
  end

  private

  def log_command_result(result)
    check_log.exit_status = result.exit_status
    check_log.raw_response = result.stdout

    if result.exit_status > 0 # rubocop:disable Style/NumericPredicate
      check_log.error = result.stderr
      check_log.status = :failed
    end

    check_log.save!
  end

  def log_parsed_response(response)
    check_log.parsed_response = response.to_json

    if response.valid?
      check_log.succeed!
    else
      check_log.failed!
    end
  end

  def log_error(exception)
    check_log.error = [exception.message, exception.backtrace].join("\n")
    check_log.failed!
  end
end
