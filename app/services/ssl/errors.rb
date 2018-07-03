module SSL
  class Error < StandardError; end

  class SSLCommandError < Error; end

  class ParserError < Error; end
  class DomainNotMatchError < ParserError; end
  class InvalidResponseError < ParserError; end
  class InvalidDateError < ParserError; end
end
