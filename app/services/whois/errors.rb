module Whois
  class Error < StandardError; end

  class WhoisCommandError < Error; end
  class UnsupportedDomainError < Error; end
  class DomainNotFoundError < Error; end
  class ParserError < Error; end

  class FieldNotFoundError < ParserError; end
  class MissingDateFormatError < ParserError; end
  class InvalidDateError < ParserError; end
end
