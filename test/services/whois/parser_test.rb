# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"
# require "whois/parser"
# require "whois/errors"

module Whois
  class ParserTest < ActiveSupport::TestCase
    test "should instanciate a parser class matching AFNIC tlds" do
      assert_kind_of Parser::AFNIC, Parser.for("example.fr")
    end

    test "should instanciate a parser class matching Verisign tlds" do
      assert_kind_of Parser::Verisign, Parser.for("example.com")
      assert_kind_of Parser::Verisign, Parser.for("example.net")
    end

    test "should instanciate a parser class matching Afilias tlds" do
      assert_kind_of Parser::Afilias, Parser.for("example.info")
    end

    test "should raises an exception when a domain is not supported" do
      assert_raises UnsupportedDomainError do
        Parser.for("example.xyz")
      end
    end
  end
end
