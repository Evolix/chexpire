# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

module Whois
  class CIRATest < ActiveSupport::TestCase
    test "should parse a whois response for .ca" do
      parser = Whois::Parser::CIRA.new("domain.ca")
      whois_output = file_fixture("whois/domain.ca.txt").read
      response = parser.parse(whois_output)
      assert_kind_of Whois::Response, response

      assert_equal Time.new(2015, 3, 24, 9, 10, 16, 0), response.created_at
      assert response.created_at.utc?

      assert_equal Time.new(2018, 12, 3, 21, 21, 04, 0), response.updated_at
      assert_equal Time.new(2020, 3, 24, 9, 10, 16, 0), response.expire_at
    end

    test "should raises DomainNotFoundError for .ca when domain is not registered" do
      parser = Whois::Parser::CIRA.new("willneverexist.ca")
      not_found = file_fixture("whois/willneverexist.ca.txt").read

      assert_raises DomainNotFoundError do
        parser.parse(not_found)
      end
    end

    test "should raises InvalidDateError for .ca when a date is not parsable" do
      parser = Whois::Parser::CIRA.new("domain.ca")
      whois_output = file_fixture("whois/domain.ca.txt").read
      whois_output.gsub!("2015-03-24T09:10:16Z", "not a date")

      assert_raises InvalidDateError do
        parser.parse(whois_output)
      end
    end
  end
end
