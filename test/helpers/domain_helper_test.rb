# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"
require "domain_helper"

class DomainHelperTest < ActiveSupport::TestCase
  include DomainHelper

  test "should normalize a domain name" do
    assert_equal "example.org", normalize_domain(" example.org ")
    assert_equal "example.org", normalize_domain("eXaMple.oRg")
  end

  test "tld should return the domain tld" do
    assert_equal ".org", tld("exaMple.ORG")
    assert_equal ".fr", tld("www.example.fr")
    assert_equal ".com", tld("www.example-dashed.com")
    assert_equal ".uk", tld("www.example.co.uk")

    assert_raises(ArgumentError) do
      tld("not a domain")
    end
  end
end
