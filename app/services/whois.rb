require "null_logger"
require "domain_helper"
require "whois/command"
require "whois/parser"
require "whois/response"

module Whois
  class << self
    def ask(domain, logger: NullLogger.new)
      Service.new(domain, logger).call
    end
  end

  class Service
    attr_reader :domain
    attr_reader :logger

    def initialize(domain, logger)
      @domain = domain
      @logger = logger
    end

    def call
      command = Command.new(domain, logger: logger)
      raw_response = command.run

      parser = Parser.for(domain, logger: logger)
      response = parser.parse(raw_response)

      response
    end
  end
end
