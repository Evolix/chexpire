# == Schema Information
#
# Table name: checks
#
#  id                :bigint(8)        not null, primary key
#  active            :boolean          default(TRUE), not null
#  comment           :string(255)
#  domain            :string(255)      not null
#  domain_created_at :datetime
#  domain_expire_at  :datetime
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

class Check < ApplicationRecord
  belongs_to :user

  enum kind: [:domain, :ssl]

  self.skip_time_zone_conversion_for_attributes = [
    :domain_created_at,
    :domain_updated_at,
    :domain_expire_at,
  ]

  validates :kind, presence: true
  validates :domain, presence: true
  validates :domain_created_at, presence: true
  validate :domain_created_at_past
  validate :domain_updated_at_past
  validates :comment, length: { maximum: 255 }
  validates :vendor, length: { maximum: 255 }

  protected

  def domain_created_at_past
    errors.add(:domain_created_at, :past) if domain_created_at.present? && domain_created_at.future?
  end

  def domain_updated_at_past
    errors.add(:domain_updated_at, :past) if domain_updated_at.present? && domain_updated_at.future?
  end
end