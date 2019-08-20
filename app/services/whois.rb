# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)


module Whois
  class Error < StandardError; end

  class CommandError < Error; end
  class UnsupportedDomainError < Error; end
  class DomainNotFoundError < Error; end
  class ParserError < Error; end

  class FieldNotFoundError < ParserError; end
  class InvalidDateError < ParserError; end

  class << self
    def ask(domain, system_klass: SystemCommand, logger: NullLogger.new)
      Service.new(domain, system_klass: system_klass, logger: logger).call
    end
  end

  class Service
    attr_reader :domain
    attr_reader :logger
    attr_reader :system_klass

    def initialize(domain, system_klass: SystemCommand, logger: NullLogger.new)
      @domain = domain
      @logger = logger
      @system_klass = system_klass
    end

    def call
      result = run_command
      parse(result)
    rescue StandardError => ex
      logger.log :service_error, ex
      raise
    end

    def run_command
      command = system_klass.new("whois", domain, logger: logger)
      result = command.execute

      unless result.exit_status.zero?
        fail Whois::CommandError, "Whois command failed with status #{result.exit_status}"
      end

      result
    end

    def parse(result)
      parser = Parser.for(domain, logger: logger)
      parser.parse(result.stdout)
    end
  end
end
