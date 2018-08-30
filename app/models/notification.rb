# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)
# == Schema Information
#
# Table name: notifications
#
#  id           :bigint(8)        not null, primary key
#  channel      :integer          default("email"), not null
#  checks_count :integer          default(0), not null
#  interval     :integer          not null
#  label        :string(255)
#  recipient    :string(255)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  check_id     :bigint(8)
#  user_id      :bigint(8)
#
# Indexes
#
#  index_notifications_on_check_id  (check_id)
#  index_notifications_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (check_id => checks.id)
#  fk_rails_...  (user_id => users.id)
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
