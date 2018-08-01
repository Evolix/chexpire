require "test_helper"

class SSLSyncJobTest < ActiveJob::TestCase
  test "calls whois database and update check with the response (domain.fr)" do
    domain = "ssl0.domain.org"
    check = create(:check, :nil_dates, domain: domain)

    mock_system_command("check_http", expected_command_arg(domain), stdout: ssl_response(domain)) do
      SSLSyncJob.perform_now(check.id)
    end

    check.reload

    assert_just_now check.last_run_at
    assert_just_now check.last_success_at
    assert_equal Time.new(2028, 6, 10, 9, 14, 18, 0), check.domain_expires_at
    assert_nil check.domain_updated_at
    assert_nil check.domain_created_at
    assert check.active?
  end

  test "ignore invalid response" do
    domain = "domain.fr"
    check = create(:check, :nil_dates, domain: domain)

    mock_system_command("check_http", expected_command_arg(domain), stdout: "not a response") do
      SSLSyncJob.perform_now(check.id)
    end

    check.reload

    assert_just_now check.last_run_at
    assert_nil check.last_success_at
    assert check.active?
    assert_equal 1, check.consecutive_failures
  end

  test "should ignore not found (removed) checks" do
    assert_nothing_raised do
      SSLSyncJob.perform_now("9999999")
    end
  end

  test "should log and re-raise StandardError" do
    check = create(:check)

    assert_raise StandardError do
      SSL.stub :ask, nil do
        SSLSyncJob.perform_now(check.id)
      end
    end

    check.reload

    assert_equal 1, check.logs.count
    assert_match(/undefined method \W+valid\?/, check.logs.last.error)
    assert check.logs.last.failed?
    assert_equal 1, check.consecutive_failures
  end

  test "should reset consecutive failures with a valid response" do
    domain = "ssl0.domain.org"
    check = create(:check, :nil_dates, domain: domain, consecutive_failures: 1)

    mock_system_command("check_http", expected_command_arg(domain), stdout: ssl_response(domain)) do
      SSLSyncJob.perform_now(check.id)
    end

    check.reload

    assert_equal 0, check.consecutive_failures
  end

  private

  def ssl_response(domain)
    file_fixture("ssl/#{domain}.txt").read
  end

  def expected_command_arg(domain)
    ["-C 0", "-H", domain]
  end
end
