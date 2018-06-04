require "test_helper"

class NotificationPolicyTest < ActiveSupport::TestCase
  setup do
    @owner, @other = create_list(:user, 2)
    @notification = create(:notification, check: build(:check, user: @owner))
  end

  test "permit to check user" do
    assert_permit @owner, @notification, :destroy
  end

  test "disallow to anonymous and other user" do
    refute_permit @other, @notification, :destroy
    refute_permit nil, @notification, :destroy
  end

  test "scope only to user checks" do
    other_notifications = create_list(:notification, 2, check: build(:check, user: @other))

    assert_empty Pundit.policy_scope!(nil, Notification)
    assert_equal [@notification], Pundit.policy_scope!(@owner, Notification)
    assert_equal other_notifications, Pundit.policy_scope!(@other, Notification)
  end

  test "disabled actions" do
    refute_permit @owner, @notification, :update
    refute_permit @owner, @notification, :edit
    refute_permit @owner, @notification, :create
    refute_permit @owner, @notification, :index
  end
end
