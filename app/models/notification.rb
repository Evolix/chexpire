# == Schema Information
#
# Table name: notifications
#
#  id         :bigint(8)        not null, primary key
#  channel    :integer          not null
#  delay      :integer          not null
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

  enum kind: [:email]
  enum status: [:pending, :ongoing, :succeed, :failed]

  validates :kind, presence: true
  validates :channel, presence: true
  validates :recipient, presence: true
  validates :delay, presence: true
end
