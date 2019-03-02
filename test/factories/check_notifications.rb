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

FactoryBot.define do
  factory :check_notification do
    check
    notification
    status { :pending }
    sent_at { nil }

    trait :ongoing do
      status { :ongoing }
    end

    trait :succeed do
      status { :succeed }
      sent_at { 1.day.ago }
    end

    trait :failed do
      status { :failed }
    end
  end
end
