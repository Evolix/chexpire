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
  belongs_to :user
  has_many :check_notifications, dependent: :destroy
  has_many :checks, -> { order(domain_expires_at: :asc) }, through: :check_notifications

  enum channel: [:email]

  validates :label, presence: true
  validates :channel, presence: true
  validates :interval, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :recipient, presence: true
end
