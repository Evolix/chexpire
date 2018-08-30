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

# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class CheckNotification < ApplicationRecord
  belongs_to :check
  belongs_to :notification, counter_cache: :checks_count

  enum status: [:pending, :ongoing, :succeed, :failed]

  scope :active_check, -> { Check.active }
  scope :check_last_run_failed, -> { Check.last_run_failed }

  def pending!
    self.sent_at = nil
    super
  end
  alias reset! pending!

  def ongoing!
    self.sent_at = Time.now
    super
  end
end
