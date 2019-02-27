# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"
require "whois/parser/afilias"
require "whois/response"
require "whois/errors"

module Whois
  class AfiliasTest < ActiveSupport::TestCase
    test "should parse a whois response for .info" do
      parser = Parser::Afilias.new("domain.info")
      whois_output = file_fixture("whois/domain.info.txt").read
      response = parser.parse(whois_output)
      assert_kind_of Response, response

      assert_equal Time.new(2006, 3, 25, 14, 1, 14, 0), response.created_at
      assert response.created_at.utc?

      assert_equal Time.new(2018, 12, 3, 21, 21, 22, 0), response.updated_at
      assert_equal Time.new(2020, 3, 25, 14, 1, 14, 0), response.expire_at
    end

    test "should raises DomainNotFoundError for .info when domain is not registered" do
      parser = Parser::Afilias.new("willneverexist.info")
      not_found = file_fixture("whois/willneverexist.info.txt").read

      assert_raises DomainNotFoundError do
        parser.parse(not_found)
      end
    end

    test "should raises InvalidDateError for .info when a date is not parsable" do
      parser = Parser::Afilias.new("domain.info")
      whois_output = file_fixture("whois/domain.info.txt").read
      whois_output.gsub!("2020-03-25T14:01:14Z", "not a date")

      assert_raises InvalidDateError do
        parser.parse(whois_output)
      end
    end

    test "should parse a whois response for .org" do
      parser = Parser::Afilias.new("domain.org")
      domain_com = file_fixture("whois/domain.org.txt").read
      response = parser.parse(domain_com)
      assert_kind_of Response, response

      assert_equal Time.new(1995, 4, 30, 4, 0, 0, 0), response.created_at
      assert response.created_at.utc?

      assert_equal Time.new(2018, 4, 2, 3, 47, 23, 0), response.updated_at
      assert_equal Time.new(2019, 5, 1, 4, 0, 0, 0), response.expire_at
    end

    test "should raises DomainNotFoundError for .org when domain is not registered" do
      parser = Parser::Afilias.new("willneverexist.org")
      not_found = file_fixture("whois/willneverexist.org.txt").read

      assert_raises DomainNotFoundError do
        parser.parse(not_found)
      end
    end

    test "should raises InvalidDateError for .org when a date is not parsable" do
      parser = Parser::Afilias.new("domain.org")
      domain_com = file_fixture("whois/domain.org.txt").read
      domain_com.gsub!("2018-04-02T03:47:23Z", "not a date")

      assert_raises InvalidDateError do
        parser.parse(domain_com)
      end
    end
  end
end
