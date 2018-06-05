# == Schema Information
#
# Table name: notifications
#
#  id         :bigint(8)        not null, primary key
#  channel    :integer          default("email"), not null
#  interval   :integer          not null
#  recipient  :string(255)      not null
#  sent_at    :datetime
#  status     :integer          default("pending"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  check_id   :bigint(8)
#
# Indexes
#
#  index_notifications_on_check_id  (check_id)
#
# Foreign Keys
#
#  fk_rails_...  (check_id => checks.id)
#

class Notification < ApplicationRecord
  belongs_to :check

  enum channel: [:email]
  enum status: [:pending, :ongoing, :succeed, :failed]

  validates :channel, presence: true
  validates :interval, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :recipient, presence: true

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
