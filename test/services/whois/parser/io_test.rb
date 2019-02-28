# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"
require "whois/parser/io"
require "whois/response"
require "whois/errors"

module Whois
  class IOTest < ActiveSupport::TestCase
    test "should parse a whois response for .io" do
      parser = Parser::IO.new("domain.io")
      whois_output = file_fixture("whois/domain.io.txt").read
      response = parser.parse(whois_output)
      assert_kind_of Response, response

      assert_equal Time.new(2016, 7, 26, 6, 16, 0, 0), response.created_at
      assert response.created_at.utc?

      assert_equal Time.new(2018, 7, 1, 13, 21, 18, 0), response.updated_at
      assert_equal Time.new(2019, 7, 26, 6, 16, 0, 0), response.expire_at
    end

    test "should raises DomainNotFoundError for .io when domain is not registered" do
      parser = Parser::IO.new("willneverexist.io")
      not_found = file_fixture("whois/willneverexist.io.txt").read

      assert_raises DomainNotFoundError do
        parser.parse(not_found)
      end
    end

    test "should raises InvalidDateError for .io when a date is not parsable" do
      parser = Parser::IO.new("domain.io")
      whois_output = file_fixture("whois/domain.io.txt").read
      whois_output.gsub!("2016-07-26T06:16:00Z", "not a date")

      assert_raises InvalidDateError do
        parser.parse(whois_output)
      end
    end
  end
end
