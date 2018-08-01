# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

class CheckDomainProcessorTest < ActiveSupport::TestCase
  setup do
    @processor = CheckDomainProcessor.new
  end

  test "process WhoisSyncJob for domain checks" do
    domain = "domain.fr"
    check = create(:check, :domain, :nil_dates, domain: domain)

    mock_system_command("whois", domain, stdout: file_fixture("whois/domain.fr.txt").read) do
      @processor.send(:process, check)
    end

    check.reload

    assert_equal Time.new(2019, 2, 17, 0, 0, 0, 0), check.domain_expires_at
  end

  test "scope concerns only checks of kind 'domain'" do
    domains = create_list(:check, 2, :domain)
    create_list(:check, 2, :ssl)

    assert_equal domains, @processor.send(:scope)
  end

  test "resolvers returns an array of methods returning a scope" do
    assert_not_empty @processor.send(:resolvers)
    @processor.send(:resolvers).each do |method|
      assert_kind_of ActiveRecord::Relation, @processor.public_send(method)
    end
  end
end
