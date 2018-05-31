require "test_helper"
require "whois/parser"
require "whois/errors"

module Whois
  class ParserTest < ActiveSupport::TestCase
    test "should instanciate a parser class matching the tld" do
      assert_kind_of Parser::Fr, Parser.for("example.fr")

      assert_raises UnsupportedDomainError do
        Parser.for("example.xyz")
      end
    end
  end
end
