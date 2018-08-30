# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)
# == Schema Information
#
# Table name: checks
#
#  id                   :bigint(8)        not null, primary key
#  active               :boolean          default(TRUE), not null
#  comment              :string(255)
#  consecutive_failures :integer          default(0), not null
#  domain               :string(255)      not null
#  domain_created_at    :datetime
#  domain_expires_at    :datetime
#  domain_updated_at    :datetime
#  kind                 :integer          not null
#  last_run_at          :datetime
#  last_success_at      :datetime
#  round_robin          :boolean          default(TRUE)
#  vendor               :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint(8)
#
# Indexes
#
#  index_checks_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require "test_helper"

class CheckTest < ActiveSupport::TestCase
  test "notifications are resetted when domain expiration date has changed" do
    check = create(:check)
    check_notification = create(:check_notification, :succeed, check: check)

    check.comment = "Will not reset because of this attribute"
    check.save!

    check_notification.reload

    assert check_notification.succeed?
    assert_not_nil check_notification.sent_at

    check.domain_expires_at = 1.year.from_now
    check.save!

    check_notification.reload

    assert check_notification.pending?
    assert_nil check_notification.sent_at
  end

  test "days_from_last_success without any success" do
    check = build(:check)
    assert_nil check.days_from_last_success

    check = build(:check, last_run_at: 1.day.ago)
    assert_nil check.days_from_last_success
  end

  test "days_from_last_success" do
    check = build(:check, last_success_at: 10.days.ago - 1.hour)
    assert_equal 10, check.days_from_last_success
  end

  test "days_from_last_success with a time" do
    check = build(:check, last_success_at: (10.1 * 24).hours.ago)
    assert_equal 10, check.days_from_last_success
  end
end
