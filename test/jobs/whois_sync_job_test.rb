require "test_helper"

class WhoisSyncJobTest < ActiveJob::TestCase
  test "calls whois database and update check with the response (domain.fr)" do
    domain = "domain.fr"
    check = create(:check, :nil_dates, domain: domain)

    mock_system_command("whois", domain, stdout: whois_response(domain)) do
      WhoisSyncJob.new.perform(check.id)
    end

    check.reload

    assert_just_now check.last_run_at
    assert_just_now check.last_success_at
    assert_equal Time.new(2019, 2, 17, 0, 0, 0, 0), check.domain_expire_at
    assert_equal Time.new(2017, 1, 28, 0, 0, 0, 0), check.domain_updated_at
    assert_equal Time.new(2004, 2, 18, 0, 0, 0, 0), check.domain_created_at
    assert check.active?
  end

  test "ignore invalid response (domain.fr)" do
    check = create(:check, :nil_dates, domain: "domain.fr")
    original_updated_at = check.updated_at

    mock_system_command("whois", "domain.fr", stdout: "not a response") do
      WhoisSyncJob.new.perform(check.id)
    end

    check.reload

    assert_just_now check.last_run_at
    assert_nil check.last_success_at
    assert_equal original_updated_at, check.updated_at
    assert check.active?
  end

  test "Disable check when whois responds domain not found" do
    domain = "willneverexist.fr"
    check = create(:check, :nil_dates, domain: domain)

    mock_system_command("whois", domain, stdout: whois_response(domain)) do
      WhoisSyncJob.new.perform(check.id)
    end

    check.reload

    refute check.active?
    assert_just_now check.last_run_at
    assert_nil check.last_success_at
  end

  private

  def whois_response(domain)
    file_fixture("whois/#{domain}.txt").read
  end

  def assert_just_now(expected)
    assert_in_delta expected.to_i, Time.now.to_i, 1.0
  end
end
