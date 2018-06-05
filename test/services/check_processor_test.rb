require "test_helper"

class CheckProcessorTest < ActiveSupport::TestCase
  setup do
    @processor = CheckProcessor.new
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

  test "raises an error for an unsupported check kind" do
    check = build(:check)

    check.stub :kind, :unknown do
      assert_raises ArgumentError do
        @processor.send(:process, check)
      end
    end
  end

  test "resolve_last_run_failed includes already and never succeeded" do
    c1 = create(:check, :last_runs_failed)
    c2 = create(:check, :last_run_succeed)
    c3 = create(:check, last_run_at: 4.days.ago, last_success_at: nil)

    checks = @processor.resolve_last_run_failed

    assert_includes checks, c1
    assert_not_includes checks, c2
    assert_includes checks, c3
  end

  test "resolve_unknown_expiry" do
    c1 = create(:check, :nil_dates)
    c2 = create(:check)

    checks = @processor.resolve_unknown_expiry

    assert_includes checks, c1
    assert_not_includes checks, c2
  end

  test "resolve_expire_short_term" do
    c1 = create(:check, :expires_next_week)
    c2 = create(:check, :expires_next_year)

    checks = @processor.resolve_expire_short_term

    assert_includes checks, c1
    assert_not_includes checks, c2
  end

  test "resolve_expire_long_term returns checks with respect of frequency" do
    c1 = create(:check, domain_expires_at: 380.days.from_now)
    c2 = create(:check, domain_expires_at: 390.days.from_now)
    c3 = create(:check, domain_expires_at: 391.days.from_now)
    c4 = create(:check, domain_expires_at: 20.days.from_now)

    checks = @processor.resolve_expire_long_term

    assert_includes checks, c1
    assert_includes checks, c2
    assert_not_includes checks, c3
    assert_not_includes checks, c4
  end

  test "resolvers does not include checks recently executed" do
    c1 = create(:check, :expires_next_week)
    c2 = create(:check, :expires_next_week, last_run_at: 4.hours.ago)

    checks = @processor.resolve_expire_short_term

    assert_includes checks, c1
    assert_not_includes checks, c2
  end

  test "resolvers include checks never executed" do
    c1 = create(:check, :expires_next_week, last_run_at: 4.days.ago)

    checks = @processor.resolve_expire_short_term

    assert_includes checks, c1
  end

  test "resolvers does not include inactive checks" do
    c1 = create(:check, :expires_next_week)
    c2 = create(:check, :expires_next_week, :inactive)

    checks = @processor.resolve_expire_short_term

    assert_includes checks, c1
    assert_not_includes checks, c2
  end

  test "#sync_dates respects the interval configuration between sends" do
    create_list(:check, 3, :expires_next_week)

    configuration = Minitest::Mock.new
    2.times do configuration.expect(:long_term, 60) end
    configuration.expect(:long_term_frequency, 10)

    3.times do
      configuration.expect(:interval, 0.000001)
    end

    processor = CheckProcessor.new(configuration)

    mock = Minitest::Mock.new
    assert_stub = lambda { |actual_time|
      assert_equal 0.000001, actual_time
      mock
    }

    processor.stub :process, nil do
      processor.stub :sleep, assert_stub do
        processor.sync_dates
      end
    end

    configuration.verify
    mock.verify
  end
end
