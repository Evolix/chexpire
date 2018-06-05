module Notifier
  class Resolver
    def resolve_expires_soon
      scope
        .where("checks.domain_expires_at >= CURDATE()")
        .where("DATE(checks.domain_expires_at)
          <= DATE_ADD(CURDATE(), INTERVAL notifications.delay DAY)")
    end

    def resolve_check_failed
      # Only gets here the checks having its last run in error
      # Logical rules are in plain ruby inside processor
      scope
        .includes(check: :logs)
        .where("checks.last_success_at <= DATE_SUB(checks.last_run_at, INTERVAL 5 MINUTE)")
    end

    private

    def scope
      Notification
        .includes(:check)
        .where(status: [:pending, :failed], checks: { active: true })
        .where.not(checks: { user: ignore_users })
    end

    def ignore_users
      @ignore_users ||= User.notifications_disabled.pluck(:id)
    end
  end
end
