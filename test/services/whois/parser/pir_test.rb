require "test_helper"
require "whois/parser/pir"
require "whois/response"
require "whois/errors"

module Whois
  class PIRTest < ActiveSupport::TestCase
    test "should parse a whois response" do
      parser = Parser::PIR.new("domain.org")
      domain_com = file_fixture("whois/domain.org.txt").read
      response = parser.parse(domain_com)
      assert_kind_of Response, response

      assert_equal Time.new(1995, 4, 30, 4, 0, 0, 0), response.created_at
      assert response.created_at.utc?

      assert_equal Time.new(2018, 4, 2, 3, 47, 23, 0), response.updated_at
      assert_equal Time.new(2019, 5, 1, 4, 0, 0, 0), response.expire_at
    end

    test "should raises DomainNotFoundError when domain is not registered" do
      parser = Parser::PIR.new("willneverexist.org")
      not_found = file_fixture("whois/willneverexist.org.txt").read

      assert_raises DomainNotFoundError do
        parser.parse(not_found)
      end
    end

    test "should raises InvalidDateError when a date is not parsable" do
      parser = Parser::PIR.new("domain.org")
      domain_com = file_fixture("whois/domain.org.txt").read
      domain_com.gsub!("2018-04-02T03:47:23Z", "not a date")

      assert_raises InvalidDateError do
        parser.parse(domain_com)
      end
    end
  end
end
