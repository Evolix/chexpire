require "test_helper"

class CheckSSLProcessorTest < ActiveSupport::TestCase
  setup do
    @processor = CheckSSLProcessor.new
  end

  test "process SSLSyncJob for ssl checks" do
    domain = "ssl0.domain.org"
    check = create(:check, :ssl, :nil_dates, domain: domain)

    response = file_fixture("ssl/ssl0.domain.org.txt").read
    mock_system_command("check_http", ["-H '#{domain}'"], stdout: response) do
      @processor.send(:process, check)
    end

    check.reload

    assert_equal Time.new(2028, 6, 10, 9, 14, 18, 0), check.domain_expires_at
  end

  test "scope concerns only checks of kind 'ssl'" do
    domains = create_list(:check, 2, :ssl)
    create_list(:check, 2, :domain)

    assert_equal domains, @processor.send(:scope)
  end

  test "resolvers returns an array of methods returning a scope" do
    assert_not_empty @processor.send(:resolvers)
    @processor.send(:resolvers).each do |method|
      assert_kind_of ActiveRecord::Relation, @processor.public_send(method)
    end
  end
end
