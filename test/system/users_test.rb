require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "an user can signup from the homepage and confirm its account" do
    visit root_path

    click_on I18n.t("shared.navbar.sign_up")
    email = "new@chexpire.org"
    password = "password"

    fill_in("user[email]", with: email)
    fill_in("user[password]", with: password)
    fill_in("user[password_confirmation]", with: password)
    check "user[tos_accepted]"

    click_button I18n.t("devise.registrations.new.sign_up")

    assert_equal root_path, page.current_path
    user = User.find_by!(email: email, confirmed_at: nil)
    assert_not_nil user

    confirmation_path = user_confirmation_path(confirmation_token: user.confirmation_token)

    confirmation_email = ActionMailer::Base.deliveries.last

    assert confirmation_email.body.include?(confirmation_path)

    visit confirmation_path
    assert_equal new_user_session_path, page.current_path
    assert page.has_css?(".alert-success")
  end

  test "an user can signin from the homepage" do
    user = users(:user1)
    visit root_path

    click_on I18n.t("shared.navbar.sign_in")

    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: "password"

    click_button I18n.t("devise.sessions.new.sign_in")

    assert_equal root_path, page.current_path
    assert page.has_content?(user.email)
  end

  test "an user can signout from the homepage" do
    user = users(:user1)

    login_as user
    visit root_path

    find ".navbar" do
      click_on user.email
      click_on I18n.t("shared.navbar.sign_out")
    end

    assert_equal root_path, page.current_path
    assert page.has_content?(I18n.t("shared.navbar.sign_in"))
  end

  test "tos must be accepted at signup" do
    visit new_user_registration_path

    email = "user@example.org"
    fill_in("user[email]", with: email)
    fill_in("user[password]", with: "password")
    fill_in("user[password_confirmation]", with: "password")

    click_button I18n.t("devise.registrations.new.sign_up")

    assert_nil User.find_by(email: email)

    within ".user_tos_accepted" do
      page.has_selector? ".invalid-feedback"
    end

    # email is prefilled
    assert_equal email, find_field("user[email]").value

    fill_in("user[password]", with: "password")
    fill_in("user[password_confirmation]", with: "password")
    check "user[tos_accepted]"

    click_button I18n.t("devise.registrations.new.sign_up")

    assert_equal root_path, page.current_path
    assert_not_nil User.find_by!(email: email, tos_accepted: true)
  end

  test "an user can globally disable its notifications" do
    user = users(:user1)
    login_as user

    visit edit_user_registration_path

    assert_equal user.email, find_field("user[email]").value

    assert find_field("user[notifications_enabled]").value
    uncheck "user[notifications_enabled]"

    fill_in("user[current_password]", with: "password")

    click_button I18n.t("devise.registrations.edit.update")

    user.reload
    refute user.notifications_enabled
  end
end
