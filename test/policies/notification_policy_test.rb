# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

class NotificationPolicyTest < ActiveSupport::TestCase
  setup do
    @owner, @other = create_list(:user, 2)
    @notification = create(:notification, user: @owner)
  end

  test "create" do
    assert_permit @other, Notification, :create
    assert_permit @other, Notification, :new
  end

  test "permit to owner" do
    assert_permit @owner, @notification, :edit
    assert_permit @owner, @notification, :update
    assert_permit @owner, @notification, :destroy
  end

  test "disallow to anonymous and other user" do
    %i[update edit destroy].each do |action|
      refute_permit @other, @notification, action
      refute_permit nil, @notification, action
    end
  end

  test "scope only to owners" do
    other_notifications = create_list(:notification, 2, user: @other)

    assert_empty Pundit.policy_scope!(nil, Notification)
    assert_equal [@notification], Pundit.policy_scope!(@owner, Notification)
    assert_equal other_notifications, Pundit.policy_scope!(@other, Notification)
  end
end
