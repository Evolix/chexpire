# == Schema Information
#
# Table name: checks
#
#  id                :bigint(8)        not null, primary key
#  active            :boolean          default(TRUE), not null
#  comment           :string(255)
#  domain            :string(255)      not null
#  domain_created_at :datetime
#  domain_expires_at :datetime
#  domain_updated_at :datetime
#  kind              :integer          not null
#  last_run_at       :datetime
#  last_success_at   :datetime
#  vendor            :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint(8)
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
    notification = create(:notification, :succeed, check: check)

    check.comment = "Will not reset because of this attribute"
    check.save!

    notification.reload

    assert notification.succeed?
    assert_not_nil notification.sent_at

    check.domain_expires_at = 1.year.from_now
    check.save!

    notification.reload

    assert notification.pending?
    assert_nil notification.sent_at
  end

  test "in_error? for recently added" do
    check = build(:check, created_at: 1.day.ago)
    refute check.in_error?

    check = build(:check, created_at: 1.day.ago, last_run_at: 3.minutes.ago)
    refute check.in_error?

    check = build(:check, created_at: 1.day.ago, last_success_at: 1.hour.ago)
    refute check.in_error?
  end

  test "in_error? for never success check, with at least 1 run" do
    check = build(:check, created_at: 3.weeks.ago, last_run_at: 1.day.ago)
    assert check.in_error?

    check = build(:check, created_at: 3.weeks.ago, last_run_at: 4.days.ago)
    assert check.in_error?
  end

  test "in_error? ignore check without run" do
    check = build(:check, created_at: 3.weeks.ago)
    refute check.in_error?
  end

  test "in_error? for last success a few days ago" do
    check = build(:check, created_at: 3.weeks.ago,
                          last_success_at: 10.days.ago, last_run_at: 1.day.ago)
    assert check.in_error?

    check = build(:check, created_at: 3.weeks.ago,
                          last_success_at: 1.days.ago, last_run_at: 1.day.ago)
    refute check.in_error?
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
