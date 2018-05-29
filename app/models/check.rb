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
  validates :active, presence: true
end
