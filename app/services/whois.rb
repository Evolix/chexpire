require "null_logger"
require "domain_helper"
require "system_command"
require_relative "whois/parser"
require_relative "whois/response"
require_relative "whois/errors"

module Whois
  class << self
    def ask(domain, system_klass: SystemCommand, logger: NullLogger.new)
      Service.new(domain, system_klass, logger: logger).call
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
    end

    def run_command
      command = system_klass.new("whois", domain, logger: logger)
      result = command.execute

      unless result.exit_status.zero?
        fail WhoisCommandError, "Whois command failed with status #{result.exit_status}"
      end

      result
    end

    def parse(result)
      parser = Parser.for(domain, logger: logger)
      parser.parse(result.stdout)
    end
  end
end
