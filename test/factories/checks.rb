# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)
# == Schema Information
#
# Table name: checks
#
#  id                   :bigint(8)        not null, primary key
#  active               :boolean          default(TRUE), not null
#  comment              :string(255)
#  consecutive_failures :integer          default(0), not null
#  domain               :string(255)      not null
#  domain_created_at    :datetime
#  domain_expires_at    :datetime
#  domain_updated_at    :datetime
#  kind                 :integer          not null
#  last_run_at          :datetime
#  last_success_at      :datetime
#  mode                 :integer          default("auto"), not null
#  round_robin          :boolean          default(TRUE)
#  vendor               :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint(8)
#
# Indexes
#
#  index_checks_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :check do
    user
    kind :domain
    domain "domain.fr"
    domain_created_at Time.new(2016, 4, 1, 12, 0, 0, "+02:00")
    domain_updated_at Time.new(2017, 3, 1, 12, 0, 0, "+02:00")
    domain_expires_at Time.new(2019, 4, 1, 12, 0, 0, "+02:00")
    active true
    vendor nil
    comment nil
    last_run_at nil
    last_success_at nil
    consecutive_failures 0
    mode :auto

    trait :domain do
      kind :domain
    end

    trait :ssl do
      kind :ssl
    end

    trait :nil_dates do
      domain_created_at nil
      domain_updated_at nil
      domain_expires_at nil
    end

    trait :expires_next_week do
      domain_expires_at 1.week.from_now
    end

    trait :expires_next_year do
      domain_expires_at 1.year.from_now
    end

    trait :last_runs_failed do
      consecutive_failures 5
      last_run_at 3.days.ago - 90.minutes
      last_success_at 7.days.ago - 2.hours
    end

    trait :last_run_succeed do
      last_run_at 25.hour.ago
      last_success_at 25.hour.ago
    end

    trait :inactive do
      active false
    end
  end
end
