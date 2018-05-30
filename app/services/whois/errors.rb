module Whois
  class UnsupportedDomainError < StandardError; end
  class ParserError < StandardError; end
  class CommentNotFoundError < ParserError; end
  class FieldNotFoundError < ParserError; end
  class MissingDateFormatError < ParserError; end
  class InvalidDateError < ParserError; end
end
