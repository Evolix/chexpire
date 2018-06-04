require "test_helper"

class NotificationsMailerTest < ActionMailer::TestCase
  test "domain_expires_soon" do
    check = create(:check, domain_expires_at: Time.new(2018, 6, 10, 12, 0, 5, "+02:00"))
    notification = build(:notification, delay: 10, check: check, recipient: "colin@example.org")

    Date.stub :today, Date.new(2018, 6, 2) do
      mail = NotificationsMailer.with(notification: notification).domain_expires_soon

      assert_emails 1 do
        mail.deliver_now
      end

      assert_match "domain.fr", mail.subject
      assert_match "in 8 days", mail.subject
      assert_equal ["colin@example.org"], mail.to
      assert_equal [Rails.configuration.chexpire.fetch("mailer_default_from")], mail.from

      parts = [mail.text_part.body.to_s, mail.html_part.to_s]

      parts.each do |part|
        assert_match "domain.fr", part
        assert_match "Sun, 10 Jun 2018 10:00:05 +0000", part
        assert_match "10 days", part
        assert_match "/checks/#{check.id}/edit", part
        assert_no_match "comment", part
        assert_no_match "vendor", part
      end
    end
  end

  test "domain_expires_soon include comment & vendor" do
    check = create(:check,
                  domain_expires_at: 1.week.from_now,
                  comment: "My comment",
                  vendor: "The vendor")
    notification = build(:notification, check: check)

    mail = NotificationsMailer.with(notification: notification).domain_expires_soon

    parts = [mail.text_part.body.to_s, mail.html_part.to_s]

    parts.each do |part|
      assert_match "My comment", part
      assert_match "The vendor", part
    end
  end

  test "domain_recurrent_failures" do
    last_success_at = Time.new(2018, 5, 30, 6, 10, 0, "+00:00")
    domain_expires_at = Time.new(2018, 10, 10, 7, 20, 0, "+04:00")
    check = build(:check, :last_runs_failed,
      domain: "invalid-domain.fr",
      last_success_at: last_success_at,
      domain_expires_at: domain_expires_at,
      comment: "My comment")
    notification = create(:notification, check: check)

    mail = NotificationsMailer.with(notification: notification).domain_recurrent_failures
    assert_match "failures", mail.subject
    assert_match "invalid-domain.fr", mail.subject

    assert_equal ["recipient@domain.fr"], mail.to
    assert_equal [Rails.configuration.chexpire.fetch("mailer_default_from")], mail.from

    parts = [mail.text_part.body.to_s, mail.html_part.to_s]

    parts.each do |part|
      assert_match "invalid-domain.fr", part
      assert_match "recurrent failures", part
      assert_match(/success[a-z ]+ Wed, 30 May 2018 06:10:00 \+0000/, part)
      assert_match(/expiry[a-z ]+ Wed, 10 Oct 2018 03:20:00 \+0000/, part)
      assert_match "My comment", part
      assert_match "/checks/#{check.id}/edit", part
    end
  end
end
