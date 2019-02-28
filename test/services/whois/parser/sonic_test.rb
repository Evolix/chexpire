# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"
require "whois/parser/sonic"
require "whois/response"
require "whois/errors"

module Whois
  class SonicTest < ActiveSupport::TestCase
    test "should parse a whois response for .so" do
      parser = Parser::Sonic.new("domain.so")
      whois_output = file_fixture("whois/domain.so.txt").read
      response = parser.parse(whois_output)
      assert_kind_of Response, response

      assert_equal Time.new(2010, 10, 31, 0, 0, 0, 0), response.created_at
      assert response.created_at.utc?

      # We can't use Time.new here
      # Sonic times have subseconds and the parsed version
      # is different than the generated time (which doesn't have
      # subseconds).
      assert_equal Time.parse("2018-11-11T11:09:47.823Z"), response.updated_at
      assert_equal Time.new(2021, 10, 31, 0, 0, 0, 0), response.expire_at
    end

    test "should raises DomainNotFoundError for .so when domain is not registered" do
      parser = Parser::Sonic.new("willneverexist.so")
      not_found = file_fixture("whois/willneverexist.so.txt").read

      assert_raises DomainNotFoundError do
        parser.parse(not_found)
      end
    end

    test "should raises InvalidDateError for .so when a date is not parsable" do
      parser = Parser::Sonic.new("domain.so")
      whois_output = file_fixture("whois/domain.so.txt").read
      whois_output.gsub!("2010-10-31T00:00:00.0Z", "not a date")

      assert_raises InvalidDateError do
        parser.parse(whois_output)
      end
    end
  end
end
