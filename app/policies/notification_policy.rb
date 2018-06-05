class NotificationPolicy < ApplicationPolicy
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
