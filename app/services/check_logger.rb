# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class CheckLogger
  attr_reader :check
  attr_reader :check_log

  def initialize(check)
    @check = check
    @check_log = CheckLog.create!(check: check, status: :pending)
    @error_logged = false
  end

  def log(event, message)
    case event
    when :after_command
      log_command_result(message)
    when :parsed_response
      log_parsed_response(message)
    when :parser_error, :service_error, :standard_error
      # avoid multiple logging & wrong incrementation of consecutive failures
      # (because a Service exception could be re-raised from a Job)
      return if error_logged?

      log_error(message)

      @error_logged = true
    end
  end

  private

  def log_command_result(result)
    check_log.exit_status = result.exit_status
    check_log.raw_response = result.stdout

    if result.exit_status.nil? || result.exit_status > 0 # rubocop:disable Style/NumericPredicate
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
    check.increment_consecutive_failures!
    check_log.error = [exception.message, exception.backtrace].join("\n")
    check_log.failed!
  end

  def error_logged?
    @error_logged
  end
end
