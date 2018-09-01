# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

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
        .auto
        .consecutive_failures(min_consecutive)
        .includes(:user)
        .where.not(user: ignore_users)
    end

    private

    def scope
      CheckNotification
        .includes(:check, :notification)
        .where(status: [:pending, :failed])
        .merge(Check.active)
        .where.not(checks: { user: ignore_users })
    end

    def ignore_users
      @ignore_users ||= User.notifications_disabled.pluck(:id)
    end
  end
end
