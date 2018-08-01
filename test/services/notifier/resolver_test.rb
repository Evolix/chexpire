require "test_helper"

module Notifier
  class ResolverTest < ActiveSupport::TestCase
    setup do
      @resolver = Notifier::Resolver.new
    end

    test "#notifications_expiring_soon ignores user having notification disabled" do
      n1 = create(:notification, check: build(:check, :expires_next_week))
      n1.check.user.update_attribute(:notifications_enabled, false)
      n2 = create(:notification, check: build(:check, :expires_next_week))

      notifications = @resolver.notifications_expiring_soon

      assert_not_includes notifications, n1
      assert_includes notifications, n2
    end

    test "#notifications_expiring_soon ignores inactive checks" do
      n1 = create(:notification, check: build(:check, :expires_next_week, :inactive))
      n2 = create(:notification, check: build(:check, :expires_next_week))

      notifications = @resolver.notifications_expiring_soon

      assert_not_includes notifications, n1
      assert_includes notifications, n2
    end

    test "#notifications_expiring_soon gets only checks inside interval" do
      n1 = create(:notification, check: build(:check, :expires_next_week), interval: 6)
      n2 = create(:notification, check: build(:check, :expires_next_week), interval: 7)

      notifications = @resolver.notifications_expiring_soon

      assert_not_includes notifications, n1
      assert_includes notifications, n2
    end

    test "#notifications_expiring_soon can gets several notifications for a same check" do
      check = create(:check, :expires_next_week)
      n1 = create(:notification, check: check, interval: 3)
      n2 = create(:notification, check: check, interval: 10)
      n3 = create(:notification, check: check, interval: 30)

      notifications = @resolver.notifications_expiring_soon

      assert_not_includes notifications, n1
      assert_includes notifications, n2
      assert_includes notifications, n3
    end

    test "#notifications_expiring_soon takes care of the status" do
      check = create(:check, :expires_next_week)
      n1 = create(:notification, check: check)
      n2 = create(:notification, :failed, check: check)
      n3 = create(:notification, :ongoing, check: check)
      n4 = create(:notification, :succeed, check: check)

      notifications = @resolver.notifications_expiring_soon

      assert_includes notifications, n1
      assert_includes notifications, n2
      assert_not_includes notifications, n3
      assert_not_includes notifications, n4
    end

    test "#notifications_expiring_soon ignores checks expired and without date" do
      n1 = create(:notification, check: build(:check, :expires_next_week))
      n2 = create(:notification, check: build(:check, domain_expires_at: 1.week.ago))
      n3 = create(:notification, check: build(:check, :nil_dates))

      notifications = @resolver.notifications_expiring_soon

      assert_includes notifications, n1
      assert_not_includes notifications, n2
      assert_not_includes notifications, n3
    end

    test "#checks_recurrent_failures ignores inactive checks" do
      c1 = create(:check, :last_runs_failed, :inactive)
      c2 = create(:check, :last_runs_failed)

      checks = @resolver.checks_recurrent_failures(4)

      assert_not_includes checks, c1
      assert_includes checks, c2
    end

    test "#checks_recurrent_failures ignores user having notification disabled" do
      c1 = create(:check, :last_runs_failed)
      c1.user.update_attribute(:notifications_enabled, false)
      c2 = create(:check, :last_runs_failed)

      checks = @resolver.checks_recurrent_failures(4)

      assert_not_includes checks, c1
      assert_includes checks, c2
    end

    test "#checks_recurrent_failures gets only checks having consecutive failures" do
      c1 = create(:check, :nil_dates)
      c2 = create(:check, :last_run_succeed)
      c3 = create(:check, :last_runs_failed, consecutive_failures: 5)
      c4 = create(:check, :last_runs_failed, consecutive_failures: 3)

      checks = @resolver.checks_recurrent_failures(4)

      assert_not_includes checks, c1
      assert_not_includes checks, c2
      assert_not_includes checks, c4
      assert_includes checks, c3
    end
  end
end
