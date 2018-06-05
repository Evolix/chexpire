require "test_helper"

module Notifier
  class ResolverTest < ActiveSupport::TestCase
    setup do
      @resolver = Notifier::Resolver.new
    end

    test "#resolve_expires_soon ignores user having notification disabled" do
      n1 = create(:notification, check: build(:check, :expires_next_week))
      n1.check.user.update_attribute(:notifications_enabled, false)
      n2 = create(:notification, check: build(:check, :expires_next_week))

      notifications = @resolver.resolve_expires_soon

      assert_not_includes notifications, n1
      assert_includes notifications, n2
    end

    test "#resolve_expires_soon ignores inactive checks" do
      n1 = create(:notification, check: build(:check, :expires_next_week, :inactive))
      n2 = create(:notification, check: build(:check, :expires_next_week))

      notifications = @resolver.resolve_expires_soon

      assert_not_includes notifications, n1
      assert_includes notifications, n2
    end

    test "#resolve_expires_soon gets only checks inside interval" do
      n1 = create(:notification, check: build(:check, :expires_next_week), interval: 6)
      n2 = create(:notification, check: build(:check, :expires_next_week), interval: 7)

      notifications = @resolver.resolve_expires_soon

      assert_not_includes notifications, n1
      assert_includes notifications, n2
    end

    test "#resolve_expires_soon can gets several notifications for a same check" do
      check = create(:check, :expires_next_week)
      n1 = create(:notification, check: check, interval: 3)
      n2 = create(:notification, check: check, interval: 10)
      n3 = create(:notification, check: check, interval: 30)

      notifications = @resolver.resolve_expires_soon

      assert_not_includes notifications, n1
      assert_includes notifications, n2
      assert_includes notifications, n3
    end

    test "#resolve_expires_soon takes care of the status" do
      check = create(:check, :expires_next_week)
      n1 = create(:notification, check: check)
      n2 = create(:notification, :failed, check: check)
      n3 = create(:notification, :ongoing, check: check)
      n4 = create(:notification, :succeed, check: check)

      notifications = @resolver.resolve_expires_soon

      assert_includes notifications, n1
      assert_includes notifications, n2
      assert_not_includes notifications, n3
      assert_not_includes notifications, n4
    end

    test "#resolve_expires_soon ignores checks expired and without date" do
      n1 = create(:notification, check: build(:check, :expires_next_week))
      n2 = create(:notification, check: build(:check, domain_expires_at: 1.week.ago))
      n3 = create(:notification, check: build(:check, :nil_dates))

      notifications = @resolver.resolve_expires_soon

      assert_includes notifications, n1
      assert_not_includes notifications, n2
      assert_not_includes notifications, n3
    end

    test "#resolve_check_failed ignores inactive checks" do
      n1 = create(:notification, check: build(:check, :last_runs_failed, :inactive))
      n2 = create(:notification, check: build(:check, :last_runs_failed))

      notifications = @resolver.resolve_check_failed

      assert_not_includes notifications, n1
      assert_includes notifications, n2
    end

    test "#resolve_check_failed ignores user having notification disabled" do
      n1 = create(:notification, check: build(:check, :last_runs_failed))
      n1.check.user.update_attribute(:notifications_enabled, false)
      n2 = create(:notification, check: build(:check, :last_runs_failed))

      notifications = @resolver.resolve_check_failed

      assert_not_includes notifications, n1
      assert_includes notifications, n2
    end

    test "#resolve_check_failed gets only checks having last run in error" do
      n1 = create(:notification, check: build(:check, :nil_dates))
      n2 = create(:notification, check: build(:check, :last_run_succeed))
      n3 = create(:notification, check: build(:check, :last_runs_failed))

      notifications = @resolver.resolve_check_failed

      assert_not_includes notifications, n1
      assert_not_includes notifications, n2
      assert_includes notifications, n3
    end
  end
end
