# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

class CheckPolicyTest < ActiveSupport::TestCase
  setup do
    @owner, @other = create_list(:user, 2)
    @check = create(:check, user: @owner)
  end

  test "create" do
    assert_permit @other, Check, :create
    assert_permit @other, Check, :new
  end

  test "check owner" do
    assert_permit @owner, @check, :update
    assert_permit @owner, @check, :edit
    assert_permit @owner, @check, :destroy
    assert_permit @owner, @check, :show
  end

  test "anonymous and other user" do
    refute_permit @other, @check, :update
    refute_permit @other, @check, :edit
    refute_permit @other, @check, :destroy
    refute_permit @other, @check, :show

    refute_permit nil, @check, :update
    refute_permit nil, @check, :edit
    refute_permit nil, @check, :destroy
    refute_permit nil, @check, :show
  end

  test "scope only to owner" do
    others = create_list(:check, 2, user: @other)

    assert_empty Pundit.policy_scope!(nil, Check)
    assert_equal [@check], Pundit.policy_scope!(@owner, Check)
    assert_equal others, Pundit.policy_scope!(@other, Check)
  end
end
