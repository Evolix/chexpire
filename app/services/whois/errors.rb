module Whois
  class WhoisError < StandardError; end

  class WhoisCommandError < WhoisError; end
  class UnsupportedDomainError < WhoisError; end
  class ParserError < WhoisError; end

  class FieldNotFoundError < ParserError; end
  class MissingDateFormatError < ParserError; end
  class InvalidDateError < ParserError; end
end
