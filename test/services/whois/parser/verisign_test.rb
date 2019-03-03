# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"
# require "whois/parser/verisign"
# require "whois/response"
# require "whois/errors"

module Whois
  class VerisignTest < ActiveSupport::TestCase
    test "should parse a whois response" do
      parser = Whois::Parser::Verisign.new("domain.com")
      domain_com = file_fixture("whois/domain.com.txt").read
      response = parser.parse(domain_com)
      assert_kind_of Whois::Response, response

      assert_equal Time.new(1994, 7, 1, 4, 0, 0, 0), response.created_at
      assert response.created_at.utc?

      assert_equal Time.new(2018, 2, 13, 18, 33, 26, 0), response.updated_at
      assert_equal Time.new(2021, 1, 7, 13, 34, 24, 0), response.expire_at
    end

    test "should raises DomainNotFoundError when domain is not registered" do
      parser = Whois::Parser::Verisign.new("willneverexist.com")
      not_found_com = file_fixture("whois/willneverexist.com.txt").read

      assert_raises DomainNotFoundError do
        parser.parse(not_found_com)
      end
    end

    test "should raises InvalidDateError when a date is not parsable" do
      parser = Whois::Parser::Verisign.new("domain.com")
      domain_com = file_fixture("whois/domain.com.txt").read
      domain_com.gsub!("2018-02-13T18:33:26Z", "not a date")

      assert_raises InvalidDateError do
        parser.parse(domain_com)
      end
    end
  end
end
