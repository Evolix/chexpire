require "application_system_test_case"

class ChecksTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
    login_as(@user)
  end

  test "create a check and a notification without kind" do
    visit new_check_path

    choose "domain"

    fill_and_valid_new_check
  end

  test "create a predefined domain check" do
    visit new_check_path(kind: :domain)

    refute page.has_css? "domain[kind]"

    fill_and_valid_new_check
  end

  test "create a predefined ssl check" do
    visit new_check_path(kind: :ssl)

    refute page.has_css? "domain[kind]"

    fill_and_valid_new_check
  end

  test "remove a notification" do
    check = create(:check, :with_notifications, domain: "dom-with-notif.net", user: @user)
    visit edit_check_path(check)
    notification = check.notifications.first

    selector = "[data-notification-id=\"#{notification.id}\"]"

    assert_difference "Notification.where(check_id: #{check.id}).count", -1 do
      within selector do
        find(".btn-danger").click
      end

      page.has_no_content?(selector)
    end
  end

  test "update a check" do
    check = create(:check, :with_notifications, domain: "dom-with-notif.net", user: @user)
    visit edit_check_path(check)

    fill_in "check[comment]", with: "My comment"

    click_button "Update Check"

    assert_equal checks_path, page.current_path

    assert page.has_css?(".alert-success")
    check.reload
    assert_equal "My comment", check.comment
  end

  test "add a notification" do
    check = create(:check, :with_notifications, domain: "dom-with-notif.net", user: @user)
    visit edit_check_path(check)

    recipient = "recipient2@example.org"
    fill_in("check[notifications_attributes][2][recipient]", with: recipient)
    fill_in("check[notifications_attributes][2][interval]", with: 55)

    assert_difference "Notification.where(check_id: #{check.id}).count", +1 do
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

  test "list my checks" do
    create(:check, :domain, domain: "dom.com", domain_expires_at: Time.new(2018, 7, 5, 12), user: @user) # rubocop:disable Metrics/LineLength
    create(:check, :ssl, domain: "ssldom.com", user: @user)
    create(:check, :ssl, domain: "ssldom2.com", user: @user)

    visit checks_path

    within ".checks-table" do
      assert page.has_content?("SSL", count: 2)
      assert page.has_content?("Domain", count: 1)
    end

    within ".check-row:first-of-type" do
      assert page.has_content?("Domain")
      assert page.has_content?("dom.com")
      assert page.has_content?("Thursday, July 5, 2018")
    end
  end

  test "list filterable by domain and ssl" do
    create_list(:check, 2, :domain, domain: "mydom.fr", user: @user)
    create_list(:check, 1, :ssl, domain: "ssl.com", user: @user)

    visit checks_path

    assert page.has_css?(".check-row", count: 3)

    within ".checks-filters" do
      click_on "Domain"
      assert find_link("Domain").matches_css? ".active"
      assert find_link("SSL").not_matches_css? ".active"
    end

    within ".checks-table" do
      assert page.has_css?(".check-row", count: 2)
      assert page.has_content?("Domain", count: 2)
    end

    within ".checks-filters" do
      click_on "SSL"
      assert find_link("SSL").matches_css? ".active"
      assert find_link("Domain").not_matches_css? ".active"
    end

    within ".checks-table" do
      assert page.has_css?(".check-row", count: 1)
      assert page.has_content?("SSL", count: 1)
      assert page.has_content?("ssl.com")
    end
  end

  test "list filterable by check in error" do
    create(:check, user: @user)
    create(:check, :last_runs_failed, created_at: 1.week.ago, user: @user)

    visit checks_path

    within ".checks-table" do
      assert page.has_css?(".check-row", count: 2)
      assert page.has_css?(".in-error", count: 1)
    end

    within ".checks-filters" do
      click_on(I18n.t("checks.filters.with_error"))
    end

    within ".checks-table" do
      assert page.has_css?(".check-row", count: 1)
      assert page.has_css?(".in-error", count: 1)
    end
  end

  test "list filterable by name string" do
    create(:check, user: @user)
    create(:check, domain: "chexpire.org", user: @user)
    create(:check, domain: "chexpire.net", user: @user)

    visit checks_path

    within ".checks-filters" do
      fill_in("by_domain", with: "chex")
      click_button
    end

    within ".checks-table" do
      assert page.has_css?(".check-row", count: 2)
      assert page.has_content?("chexpire.", count: 2)
    end
  end

  test "list is paginated" do
    create(:check, user: @user)

    visit checks_path
    assert page.has_no_css?("ul.pagination")

    create_list(:check, 50, user: @user)

    visit checks_path
    assert page.has_css?("ul.pagination")
  end

  test "list is sortable by name" do
    visit checks_path

    create(:check, domain: "a.org", user: @user)
    create(:check, domain: "b.org", user: @user)

    visit checks_path

    within ".checks-table thead th:nth-of-type(2)" do
      find(".sort-links:first-child").click
    end

    within ".check-row:first-of-type" do
      page.has_content? "a.org"
    end

    within ".checks-table thead th:nth-of-type(2)" do
      find(".sort-links:last-child").click
    end

    within ".check-row:first-of-type" do
      page.has_content? "b.org"
    end
  end

  test "list is sorted by expiration date by default" do
    visit checks_path

    create(:check, domain_expires_at: Time.new(2018, 7, 6, 12), user: @user)
    create(:check, domain_expires_at: Time.new(2018, 7, 5, 12), user: @user)

    visit checks_path

    within ".check-row:first-of-type" do
      page.has_content? "Thursday, July 5, 2018"
    end
  end

  test "list is sortable by expiration date" do
    visit checks_path

    create(:check, domain_expires_at: Time.new(2018, 7, 5, 12), user: @user)
    create(:check, domain_expires_at: Time.new(2018, 7, 6, 12), user: @user)

    visit checks_path

    within ".check-row:first-of-type" do
      page.has_content? "Thursday, July 5, 2018"
    end

    # only a desc link because of default sort
    within ".checks-table thead th:nth-of-type(3)" do
      find(".sort-links a").click
    end

    within ".check-row:first-of-type" do
      page.has_content? "Friday, July 6, 2018"
    end

    within ".checks-table thead th:nth-of-type(3)" do
      find(".sort-links a").click
    end

    within ".check-row:first-of-type" do
      page.has_content? "Thursday, July 5, 2018"
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def fill_and_valid_new_check
    domain = "domain-test.fr"
    fill_in("check[domain]", with: domain)

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
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
