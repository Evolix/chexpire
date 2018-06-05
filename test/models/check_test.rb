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
end
