# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class CheckNotificationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:check).where(checks: { user: user })
    end
  end

  def destroy?
    check_owner?
  end

  def show?
    false
  end

  private

  def check_owner?
    record.check.user == user
  end
end
