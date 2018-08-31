# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

class CheckNotificationPolicyTest < ActiveSupport::TestCase
  setup do
    @owner, @other = create_list(:user, 2)
    @check_notification = create(:check_notification, check: build(:check, user: @owner))
  end

  test "permit to check user" do
    assert_permit @owner, @check_notification, :destroy
  end

  test "disallow to anonymous and other user" do
    refute_permit @other, @check_notification, :destroy
    refute_permit nil, @check_notification, :destroy
  end

  test "scope only to user checks" do
    other_notifications = create_list(:check_notification, 2, check: build(:check, user: @other))

    assert_empty Pundit.policy_scope!(nil, CheckNotification)
    assert_equal [@check_notification], Pundit.policy_scope!(@owner, CheckNotification)
    assert_equal other_notifications, Pundit.policy_scope!(@other, CheckNotification)
  end

  test "disabled actions" do
    refute_permit @owner, @check_notification, :update
    refute_permit @owner, @check_notification, :edit
    refute_permit @owner, @check_notification, :create
    refute_permit @owner, @check_notification, :index
  end
end
