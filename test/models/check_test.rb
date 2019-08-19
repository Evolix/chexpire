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
#  mode                 :integer          default("auto"), not null
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

  test "consecutive failures are resetted when domain changed" do
    check = create(:check, consecutive_failures: 1)

    check.domain = "mynewdomain.fr"
    check.save!

    assert_equal 0, check.consecutive_failures
  end

  test "consecutive failures are resetted when mode changed" do
    check = create(:check, consecutive_failures: 1, mode: :auto)
    check.manual!

    assert_equal 0, check.consecutive_failures

    check = create(:check, domain: "x.wxyz", consecutive_failures: 1, mode: :manual)
    check.auto!

    assert_equal 0, check.consecutive_failures
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

  test "supported? for domain" do
    check = build(:check, :domain, domain: "domain.fr")
    assert check.supported?

    check = build(:check, :domain, domain: "domain.cn")
    refute check.supported?

    # an empty domain name is still considered as supported
    check = build(:check, :domain, domain: "")
    assert check.supported?
  end

  test "supported? for SSL" do
    check = build(:check, :ssl)
    assert check.supported?

    check = build(:check, :ssl, domain: "domain.cn")
    assert check.supported?
  end

  test "set mode before saving" do
    check = build(:check, domain: "domain.fr")
    check.save!
    assert check.auto?

    check.domain = "domain.xyz"
    check.save!
    assert check.mode?
  end

  test "expiration in days (future)" do
    check = create(:check, domain_expires_at: 1.week.from_now)

    assert_equal 7, check.domain_expires_in_days
  end

  test "expiration in days (past)" do
    check = create(:check, domain_expires_at: 1.week.ago)

    assert_equal -7, check.domain_expires_in_days
  end
end
