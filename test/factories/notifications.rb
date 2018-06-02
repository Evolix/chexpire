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

FactoryBot.define do
  factory :notification do
    check
    delay 30
    channel :email
    recipient "recipient@domain.fr"
    status :pending
    sent_at nil

    trait :email do
      channel :email
    end

    trait :ongoing do
      status :ongoing
    end

    trait :succeed do
      status :succeed
    end

    trait :failed do
      status :failed
    end
  end
end
