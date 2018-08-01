module Notifier
  class Resolver
    def notifications_expiring_soon
      scope
        .where("checks.domain_expires_at >= CURDATE()")
        .where("DATE(checks.domain_expires_at)
          <= DATE_ADD(CURDATE(), INTERVAL notifications.interval DAY)")
    end

    def checks_recurrent_failures(min_consecutive)
      Check
        .active
        .consecutive_failures(min_consecutive)
        .includes(:user)
        .where.not(user: ignore_users)
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
