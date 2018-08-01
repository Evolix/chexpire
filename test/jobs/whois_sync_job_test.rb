require "test_helper"

class WhoisSyncJobTest < ActiveJob::TestCase
  test "calls whois database and update check with the response (domain.fr)" do
    domain = "domain.fr"
    check = create(:check, :nil_dates, domain: domain)

    mock_system_command("whois", domain, stdout: whois_response(domain)) do
      WhoisSyncJob.perform_now(check.id)
    end

    check.reload

    assert_just_now check.last_run_at
    assert_just_now check.last_success_at
    assert_equal Time.new(2019, 2, 17, 0, 0, 0, 0), check.domain_expires_at
    assert_equal Time.new(2017, 1, 28, 0, 0, 0, 0), check.domain_updated_at
    assert_equal Time.new(2004, 2, 18, 0, 0, 0, 0), check.domain_created_at
    assert check.active?
  end

  test "ignore invalid response (domain.fr)" do
    check = create(:check, :nil_dates, domain: "domain.fr")
    original_updated_at = check.updated_at

    mock_system_command("whois", "domain.fr", stdout: "not a response") do
      WhoisSyncJob.perform_now(check.id)
    end

    check.reload

    assert_just_now check.last_run_at
    assert_nil check.last_success_at
    assert_equal original_updated_at, check.updated_at
    assert check.active?
    assert_equal 1, check.consecutive_failures
  end

  test "should ignore not found (removed) checks" do
    assert_nothing_raised do
      WhoisSyncJob.perform_now("9999999")
    end
  end

  test "should log and re-raise StandardError" do
    check = create(:check)

    assert_raise StandardError do
      Whois.stub :ask, nil do
        WhoisSyncJob.perform_now(check.id)
      end
    end

    check.reload

    assert_equal 1, check.logs.count
    assert_match(/undefined method \W+valid\?/, check.logs.last.error)
    assert check.logs.last.failed?
    assert_equal 1, check.consecutive_failures
  end

  test "disable check when whois responds domain not found" do
    domain = "willneverexist.fr"
    check = create(:check, :nil_dates, domain: domain)

    mock_system_command("whois", domain, stdout: whois_response(domain)) do
      WhoisSyncJob.perform_now(check.id)
    end

    check.reload

    refute check.active?
    assert_just_now check.last_run_at
    assert_nil check.last_success_at
    assert_equal 1, check.consecutive_failures
  end

  test "default logger is CheckLogger" do
    check = create(:check)

    mock_system_command("whois", check.domain) do
      WhoisSyncJob.perform_now(check.id)
    end

    assert_equal 1, check.logs.count
  end

  test "should reset consecutive failures with a valid response" do
    domain = "domain.fr"
    check = create(:check, :nil_dates, domain: domain, consecutive_failures: 1)

    mock_system_command("whois", domain, stdout: whois_response(domain)) do
      WhoisSyncJob.perform_now(check.id)
    end

    check.reload

    assert_equal 0, check.consecutive_failures
  end

  private

  def whois_response(domain)
    file_fixture("whois/#{domain}.txt").read
  end
end
