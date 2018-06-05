require "application_system_test_case"

class ChecksTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
    login_as(@user)

    @check = create(:check, :with_notifications, user: @user)
  end

  test "create a check and a notification" do
    visit new_check_path

    domain = "domain-test.fr"
    fill_in("check[domain]", with: domain)
    choose "domain"

    recipient = "recipient@example.org"
    fill_in("check[notifications_attributes][0][recipient]", with: recipient)
    fill_in("check[notifications_attributes][0][interval]", with: 30)

    click_button

    assert_equal checks_path, page.current_path

    assert page.has_css?(".alert-success")
    assert page.has_content?(domain)

    notification = Notification.last
    assert_equal recipient, notification.recipient
    assert_equal 30, notification.interval
    assert notification.email?
    assert notification.pending?
  end

  test "remove a notification" do
    visit edit_check_path(@check)
    notification = @check.notifications.first

    selector = "[data-notification-id=\"#{notification.id}\"]"

    assert_difference "Notification.where(check_id: #{@check.id}).count", -1 do
      within selector do
        find(".btn-danger").click
      end

      page.has_no_content?(selector)
    end
  end

  test "update a check" do
    visit edit_check_path(@check)

    fill_in "check[comment]", with: "My comment"

    click_button "Update Check"

    assert_equal checks_path, page.current_path

    assert page.has_css?(".alert-success")
    @check.reload
    assert_equal "My comment", @check.comment
  end

  test "add a notification" do
    visit edit_check_path(@check)

    recipient = "recipient2@example.org"
    fill_in("check[notifications_attributes][2][recipient]", with: recipient)
    fill_in("check[notifications_attributes][2][interval]", with: 55)

    assert_difference "Notification.where(check_id: #{@check.id}).count", +1 do
      click_button "Update Check"

      assert_equal checks_path, page.current_path
    end

    assert page.has_css?(".alert-success")

    notification = Notification.last
    assert_equal recipient, notification.recipient
    assert_equal 55, notification.interval
    assert notification.email?
    assert notification.pending?
  end
end
