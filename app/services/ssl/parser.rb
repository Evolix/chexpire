require "null_logger"
require "ssl/errors"

module SSL
  class Parser
    DATE_REGEX = /will expire on (.+)\./
    # Several date formats possible:
    # OK - Certificate 'domain.net' will expire on Sat 10 Jun 2028 09:14:18 AM GMT +0000.
    # OK - Certificate 'domain.net' will expire on 2018-08-06 02:57 +0200/CEST.

    attr_reader :logger
    attr_reader :domain

    def initialize(domain, logger: NullLogger.new)
      @logger = logger
      @domain = domain
    end

    def parse(raw)
      fail DomainNotMatchError unless match_domain?(raw)

      match = raw.match(DATE_REGEX)

      fail InvalidResponseError unless match.present?

      response = build_response(match)

      logger.log :parsed_response, response

      response
    rescue ParserError => ex
      logger.log :parser_error, ex
      raise
    end

    def match_domain?(raw)
      raw.match(/\b#{domain}\b/).present?
    end

    def build_response(match)
      Response.new(domain).tap do |response|
        response.expire_at = parse_datetime(match[1])
      end
    end

    def parse_datetime(date_str)
      Time.parse(date_str).utc
    rescue StandardError => ex
      raise InvalidDateError, ex.message
    end
  end
end
