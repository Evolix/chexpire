# == Schema Information
#
# Table name: check_notifications
#
#  id              :bigint(8)        not null, primary key
#  sent_at         :datetime
#  status          :integer          default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  check_id        :bigint(8)
#  notification_id :bigint(8)
#
# Indexes
#
#  index_check_notifications_on_check_id         (check_id)
#  index_check_notifications_on_notification_id  (notification_id)
#
# Foreign Keys
#
#  fk_rails_...  (check_id => checks.id)
#  fk_rails_...  (notification_id => notifications.id)
#

require 'test_helper'

class CheckNotificationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
