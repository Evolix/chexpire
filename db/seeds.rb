# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

CheckLog.destroy_all
Notification.destroy_all
Check.destroy_all
User.destroy_all

user1 = User.create!(
  email: "colin@example.org",
  password: "password",
  tos_accepted: true,
  confirmed_at: Time.now,
  locale: :fr,
)

user2 = User.create!(
  email: "colin+en@example.org",
  password: "password",
  tos_accepted: true,
  confirmed_at: Time.now,
  locale: :en,
)

users = [user1, user2]

check_chexpire_org = Check.create!(
  user: user1,
  kind: :domain,
  domain: "chexpire.org",
  domain_expires_at: 1.week.from_now,
  domain_updated_at: 6.months.ago,
  domain_created_at: Time.new(2016, 8, 4, 12, 15, 1),
  comment: "The date are fake, this is a seed !",
  vendor: "Some random registrar",
)

check_chexpire_org_error = Check.create!(
  user: user1,
  kind: :domain,
  domain: "chexpire-error.org",
  domain_expires_at: 1.week.from_now,
  domain_updated_at: 6.months.ago,
  domain_created_at: Time.new(2016, 8, 4, 12, 15, 1),
  comment: "The date are fake, this is a seed !",
  vendor: "Some random registrar",
  last_run_at: 20.minutes.ago,
  created_at: 3.weeks.ago,
  consecutive_failures: 4,
)

ssl_check_chexpire_org = Check.create!(
  user: user1,
  kind: :ssl,
  domain: "www.chexpire.org",
  domain_expires_at: 1.week.from_now,
  domain_updated_at: 6.months.ago,
  domain_created_at: Time.new(2016, 8, 4, 12, 15, 1),
  comment: "The date are fake, this is a seed !",
  vendor: "Some random registrar",
)

ssl_check_chexpire_org_error = Check.create!(
  user: user1,
  kind: :ssl,
  domain: "chexpire-error.org",
  domain_expires_at: 1.week.from_now,
  domain_updated_at: 6.months.ago,
  domain_created_at: Time.new(2016, 8, 4, 12, 15, 1),
  comment: "The date are fake, this is a seed !",
  vendor: "Some random registrar",
  last_run_at: 20.minutes.ago,
  last_success_at: 4.days.ago,
  consecutive_failures: 8,
)


def check_factory(users)
  ext = %w[com net org fr].sample
  word = (0...rand(4..12)).map { (97 + rand(26)).chr }.join

  Check.new(
    user: users.sample,
    kind: Check.kinds.keys.sample,
    domain: "#{word}.#{ext}",
    domain_expires_at: rand(8..300).days.from_now,
    domain_updated_at: rand(1..300).days.ago,
    domain_created_at: rand(301..3000).days.ago,
  )
end

100.times do |i|
  check_factory(users).save!
end

# checks with error
10.times do |i|
  check_factory(users).update_attributes(
    created_at: rand(1..300).days.ago,
    last_run_at: 4.hours.ago,
    last_success_at: rand(10...100).days.ago,
  )
end

Notification.create!(
  check: check_chexpire_org,
  interval: 15,
  channel: :email,
  recipient: "colin@example.org",
  status: :pending,
)

Notification.create!(
  check: check_chexpire_org_error,
  interval: 15,
  channel: :email,
  recipient: "colin@example.org",
  status: :pending,
)

Notification.create!(
  check: ssl_check_chexpire_org,
  interval: 15,
  channel: :email,
  recipient: "colin@example.org",
  status: :pending,
)

Notification.create!(
  check: ssl_check_chexpire_org_error,
  interval: 15,
  channel: :email,
  recipient: "colin@example.org",
  status: :pending,
)

puts "\e[0;32mDone 👌\e[0m"
puts " "
puts "--------------------"
puts "Users: #{User.count}"
puts "Checks: #{Check.count}"
puts "Notifications: #{Notification.count}"
