# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

class NotificationsMailerTest < ActionMailer::TestCase # rubocop:disable Metrics/ClassLength
  test "domain_expires_soon" do
    expiration_date = 8.days.from_now.utc
    check = create(:check, domain_expires_at: expiration_date)
    notification = build(:notification, interval: 10, recipient: "colin@example.org")
    check_notification = build(:check_notification, check: check, notification: notification)

    mail = NotificationsMailer.with(check_notification: check_notification).domain_expires_soon

    assert_emails 1 do
      mail.deliver_now
    end

    assert_match "domain.fr", mail.subject
    assert_match "in 8 days", mail.subject
    assert_equal ["colin@example.org"], mail.to
    assert_equal [Rails.configuration.chexpire.fetch("mailer_default_from")], mail.from

    parts = [mail.text_part.decode_body, mail.html_part.decode_body]

    parts.each do |part|
      assert_match "domain.fr", part
      assert_match I18n.l(expiration_date, locale: :en), part
      assert_match "10 days", part
      assert_match "/checks/#{check.id}/edit", part
      assert_no_match "comment", part
      assert_no_match "vendor", part
    end
  end

  test "domain_expires_soon FR" do
    expiration_date = 8.days.from_now.utc
    check = create(:check,
                  domain_expires_at: expiration_date,
                  user: build(:user, :fr))
    notification = build(:notification, interval: 10, recipient: "colin@example.org")
    check_notification = build(:check_notification, check: check, notification: notification)

    mail = NotificationsMailer.with(check_notification: check_notification).domain_expires_soon

    assert_emails 1 do
      mail.deliver_now
    end

    assert_match "domain.fr", mail.subject
    assert_match "dans 8 jours", mail.subject
    assert_equal ["colin@example.org"], mail.to
    assert_equal [Rails.configuration.chexpire.fetch("mailer_default_from")], mail.from

    parts = [mail.text_part.decode_body, mail.html_part.decode_body]

    parts.each do |part|
      assert_match "domain.fr", part
      assert_match I18n.l(expiration_date, locale: :fr), part
      assert_match "10 jours", part
      assert_match "/checks/#{check.id}/edit", part
      assert_no_match "commentaire", part
      assert_no_match "fournisseur", part
    end
  end

  test "domain_expires_soon include comment & vendor" do
    check = create(:check,
                  domain_expires_at: 1.week.from_now,
                  comment: "My comment",
                  vendor: "The vendor")
    check_notification = build(:check_notification, check: check)

    mail = NotificationsMailer.with(check_notification: check_notification).domain_expires_soon

    parts = [mail.text_part.decode_body, mail.html_part.decode_body]

    parts.each do |part|
      assert_match "My comment", part
      assert_match "The vendor", part
    end
  end

  test "domain_expires_soon include comment & vendor - FR" do
    check = create(:check,
                  domain_expires_at: 1.week.from_now,
                  comment: "My comment",
                  vendor: "The vendor",
                  user: build(:user, :fr))
    check_notification = build(:check_notification, check: check)

    mail = NotificationsMailer.with(check_notification: check_notification).domain_expires_soon

    parts = [mail.text_part.decode_body, mail.html_part.decode_body]

    parts.each do |part|
      assert_match "commentaire", part
      assert_match "Fournisseur", part
    end
  end

  test "recurrent_failures" do
    last_success_at = Time.new(2018, 5, 30, 6, 10, 0, "+00:00")
    domain_expires_at = Time.new(2018, 10, 10, 7, 20, 0, "+04:00")
    check = create(:check, :last_runs_failed,
                  domain: "invalid-domain.fr",
                  last_success_at: last_success_at,
                  domain_expires_at: domain_expires_at,
                  comment: "My comment")

    mail = NotificationsMailer.recurrent_failures(check.user, [check])
    assert_match "failures", mail.subject
    assert_match "invalid-domain.fr", mail.subject

    assert_match(/user-\d+@chexpire.org/, mail.to.first)
    assert_equal [Rails.configuration.chexpire.fetch("mailer_default_from")], mail.from

    parts = [mail.text_part.decode_body, mail.html_part.decode_body]

    parts.each do |part|
      assert_match "invalid-domain.fr", part
      assert_match "recurrent failures", part
      assert_match(/success[a-z: ]+ Wed, 30 May 2018 06:10:00 \+0000/, part)
      assert_match(/expiry[a-z: ]+ Wed, 10 Oct 2018 03:20:00 \+0000/, part)
      assert_match "My comment", part
      assert_match "/checks/#{check.id}/edit", part
    end
  end

  test "recurrent_failures - FR" do
    last_success_at = Time.new(2018, 5, 30, 6, 10, 0, "+00:00")
    domain_expires_at = Time.new(2018, 10, 10, 7, 20, 0, "+04:00")
    check = create(:check, :last_runs_failed,
                  domain: "invalid-domain.fr",
                  last_success_at: last_success_at,
                  domain_expires_at: domain_expires_at,
                  comment: "My comment",
                  user: build(:user, :fr))

    mail = NotificationsMailer.recurrent_failures(check.user, [check])
    assert_match "Erreurs", mail.subject
    assert_match "invalid-domain.fr", mail.subject

    assert_match(/user-\d+@chexpire.org/, mail.to.first)
    assert_equal [Rails.configuration.chexpire.fetch("mailer_default_from")], mail.from

    parts = [mail.text_part.decode_body, mail.html_part.decode_body]

    parts.each do |part|
      assert_match "invalid-domain.fr", part
      assert_match "erreurs", part
      assert_match(/réussie[a-z: ]+ mer 30 mai 2018 06:10:00 \+0000/, part)
      assert_match(/expiration[a-z: ]+ mer 10 oct. 2018 03:20:00 \+0000/, part)
      assert_match "commentaire", part
      assert_match "/checks/#{check.id}/edit", part
    end
  end

  test "ssl_expires_soon" do
    expiration_date = 8.days.from_now.utc
    check = create(:check, :ssl, domain_expires_at: 8.days.from_now)
    notification = build(:notification, interval: 10, recipient: "colin@example.org")
    check_notification = build(:check_notification, check: check, notification: notification)

    mail = NotificationsMailer.with(check_notification: check_notification).ssl_expires_soon

    assert_emails 1 do
      mail.deliver_now
    end

    assert_match "domain.fr", mail.subject
    assert_match "SSL", mail.subject
    assert_match "in 8 days", mail.subject
    assert_equal ["colin@example.org"], mail.to
    assert_equal [Rails.configuration.chexpire.fetch("mailer_default_from")], mail.from

    parts = [mail.text_part.decode_body, mail.html_part.decode_body]

    parts.each do |part|
      assert_match "domain.fr", part
      assert_match I18n.l(expiration_date, locale: :en), part
      assert_match "10 days", part
      assert_match "/checks/#{check.id}/edit", part
      assert_no_match "comment", part
      assert_no_match "vendor", part
    end
  end

  test "ssl_expires_soon - FR" do
    expiration_date = 8.days.from_now.utc
    check = create(:check, :ssl,
                  domain_expires_at: expiration_date,
                  user: build(:user, :fr))
    notification = build(:notification, interval: 10, recipient: "colin@example.org")
    check_notification = build(:check_notification, check: check, notification: notification)

    mail = NotificationsMailer.with(check_notification: check_notification).ssl_expires_soon

    assert_emails 1 do
      mail.deliver_now
    end

    assert_match "domain.fr", mail.subject
    assert_match "SSL", mail.subject
    assert_match "dans 8 jours", mail.subject
    assert_equal ["colin@example.org"], mail.to
    assert_equal [Rails.configuration.chexpire.fetch("mailer_default_from")], mail.from

    parts = [mail.text_part.decode_body, mail.html_part.decode_body]

    parts.each do |part|
      assert_match "domain.fr", part
      assert_match I18n.l(expiration_date, locale: :fr), part
      assert_match "10 jours", part
      assert_match "/checks/#{check.id}/edit", part
      assert_no_match "commentaire", part
      assert_no_match "fournisseur", part
    end
  end
end
