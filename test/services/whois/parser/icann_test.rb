# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

module Whois
  class IcannTest < ActiveSupport::TestCase
    test "should parse a whois response for .org" do
      parser = Whois::Parser::Icann.new("domain.org")
      domain_com = file_fixture("whois/domain.org.txt").read
      response = parser.parse(domain_com)
      assert_kind_of Whois::Response, response

      assert_equal Time.new(2002, 11, 18, 18, 8, 13, 0), response.created_at
      assert response.created_at.utc?

      assert_equal Time.new(2022, 6, 3, 22, 27, 15, 0), response.updated_at
      assert_equal Time.new(2022, 11, 18, 18, 8, 13, 0), response.expire_at
    end

    test "should raises DomainNotFoundError for .org when domain is not registered" do
      parser = Whois::Parser::Icann.new("willneverexist.org")
      not_found = file_fixture("whois/willneverexist.org.txt").read

      assert_raises DomainNotFoundError do
        parser.parse(not_found)
      end
    end

    test "should raises InvalidDateError for .org when a date is not parsable" do
      parser = Whois::Parser::Icann.new("domain.org")
      domain_com = file_fixture("whois/domain.org.txt").read
      # replace one of the dates with something that is not a date
      domain_com.gsub!("2002-11-18T18:08:13Z", "not a date")

      assert_raises InvalidDateError do
        parser.parse(domain_com)
      end
    end
  end
end
