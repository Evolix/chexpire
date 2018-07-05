require "null_logger"
require "system_command"
require_relative "ssl/parser"
require_relative "ssl/response"
require_relative "ssl/errors"

module SSL
  class << self
    def ask(domain, system_klass: SystemCommand, logger: NullLogger.new)
      Service.new(domain, system_klass: system_klass, logger: logger).call
    end
  end

  class Service
    attr_reader :domain
    attr_reader :logger
    attr_reader :system_klass
    attr_reader :configuration

    def initialize(domain, system_klass: SystemCommand, configuration: nil, logger: NullLogger.new)
      @domain = domain
      @logger = logger
      @system_klass = system_klass
      @configuration = configuration || default_configuration
    end

    def call
      result = run_command
      parse(result)
    rescue StandardError => ex
      logger.log :service_error, ex
      raise
    end

    def run_command
      command = system_klass.new(check_http_path, check_http_args, logger: logger)

      result = command.execute

      unless result.exit_status.zero?
        fail SSLCommandError, "SSL command failed with status #{result.exit_status}"
      end

      result
    end

    def parse(result)
      parser = Parser.new(domain, logger: logger)
      parser.parse(result.stdout)
    end

    def check_http_path
      configuration.check_http_path.presence || "check_http"
    end

    def check_http_args
      [
        "-C 0", # enable SSL mode without any delay warning
        "-H",   # check_http does not works with fully quoted arg (check_http "-H myhost.org")
        domain,
        *custom_check_http_args,
      ].compact
    end

    def custom_check_http_args
      return nil unless configuration.check_http_args.present?

      fail SSLConfigurationError, "check_http_args option must be an array of argument." \
        unless configuration.check_http_args.is_a?(Array)

      configuration.check_http_args
    end

    def default_configuration
      OpenStruct.new(Rails.configuration.chexpire.fetch("checks_ssl") { {} })
    end
  end
end
