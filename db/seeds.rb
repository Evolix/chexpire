Notification.destroy_all
Check.destroy_all
User.destroy_all

user1 = User.create!(
  email: "colin@example.org",
  password: "password",
  tos_accepted: true,
  confirmed_at: Time.now
)

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
  domain: "chexpire.org",
  domain_expires_at: 1.week.from_now,
  domain_updated_at: 6.months.ago,
  domain_created_at: Time.new(2016, 8, 4, 12, 15, 1),
  comment: "The date are fake, this is a seed !",
  vendor: "Some random registrar",
  last_run_at: 20.minutes.ago,
  last_success_at: 4.days.ago,
)

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

puts "\e[0;32mDone 👌\e[0m"
puts " "
puts "--------------------"
puts "Users: #{User.count}"
puts "Checks: #{Check.count}"
puts "Notifications: #{Notification.count}"
