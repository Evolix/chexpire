module Notifier
  class Resolver
    def resolve_expires_soon
      scope
        .where("checks.domain_expires_at >= CURDATE()")
        .where("DATE(checks.domain_expires_at)
          <= DATE_ADD(CURDATE(), INTERVAL notifications.interval DAY)")
    end

    def resolve_check_failed
      # Only gets here the checks having its last run in error
      # Logical rules are in plain ruby inside processor
      scope
        .includes(check: :logs)
        .merge(Check.last_run_failed)
    end

    private

    def scope
      Notification
        .includes(:check)
        .where(status: [:pending, :failed])
        .merge(Check.active)
        .where.not(checks: { user: ignore_users })
    end

    def ignore_users
      @ignore_users ||= User.notifications_disabled.pluck(:id)
    end
  end
end
