require "test_helper"

class ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    login_as(@user)
  end

  test "no logged users are redirected to signin form" do
    logout
    get new_check_path
    assert_redirected_to new_user_session_path
  end

  test "new without kind does not trigger an error" do
    get new_check_path
    assert_response :success
  end

  test "new with kind domain does not trigger an error" do
    get new_check_path(kind: :domain)
    assert_response :success
  end

  test "new with kind ssl does not trigger an error" do
    get new_check_path(kind: :ssl)
    assert_response :success
  end

  test "new with an invalid kind returns an error" do
    get new_check_path(kind: :invalid)
    assert_response :not_found
  end

  test "checks are ordered by default by expiry date sort" do
    c1 = create(:check, user: @user, domain_expires_at: 20.days.from_now)
    c2 = create(:check, user: @user, domain_expires_at: 10.days.from_now)
    c3 = create(:check, user: @user, domain_expires_at: 1.day.from_now)

    get checks_path
    assert_equal [c3, c2, c1], current_checks
  end

  test "checks are ordered by expiry date asc" do
    c1 = create(:check, user: @user, domain_expires_at: 20.days.from_now)
    c2 = create(:check, user: @user, domain_expires_at: 10.days.from_now)
    c3 = create(:check, user: @user, domain_expires_at: 1.day.from_now)

    get checks_path(sort: :domain_expires_at_asc)
    assert_equal [c3, c2, c1], current_checks
  end

  test "checks are ordered by reverse expiring date" do
    c1 = create(:check, user: @user, domain_expires_at: 1.day.from_now)
    c2 = create(:check, user: @user, domain_expires_at: 10.days.from_now)
    c3 = create(:check, user: @user, domain_expires_at: 20.days.from_now)

    get checks_path(sort: :domain_expires_at_desc)
    assert_equal [c3, c2, c1], current_checks
  end

  test "checks are ordered by domain name asc" do
    c1 = create(:check, user: @user, domain: "a")
    c2 = create(:check, user: @user, domain: "b")
    c3 = create(:check, user: @user, domain: "c")

    get checks_path(sort: :domain_asc)
    assert_equal [c1, c2, c3], current_checks
  end

  test "checks are ordered by domain name desc" do
    c1 = create(:check, user: @user, domain: "a")
    c2 = create(:check, user: @user, domain: "b")
    c3 = create(:check, user: @user, domain: "c")

    get checks_path(sort: :domain_desc)
    assert_equal [c3, c2, c1], current_checks
  end

  test "invalid sort fallback to default sort" do
    c1 = create(:check, user: @user, domain_expires_at: 20.days.from_now)
    c2 = create(:check, user: @user, domain_expires_at: 10.days.from_now)
    c3 = create(:check, user: @user, domain_expires_at: 1.day.from_now)

    get checks_path(sort: :invalid_sort_asc)
    assert_equal [c3, c2, c1], current_checks
  end

  test "checks are filtered by domain kind" do
    c1 = create(:check, :domain, user: @user)
    c2 = create(:check, :domain, user: @user)
    create(:check, :ssl, user: @user)

    get checks_path(kind: :domain)
    assert_equal [c1, c2], current_checks
  end

  test "checks are filtered by ssl kind" do
    create(:check, :domain, user: @user)
    create(:check, :domain, user: @user)
    c3 = create(:check, :ssl, user: @user)

    get checks_path(kind: :ssl)
    assert_equal [c3], current_checks
  end

  test "checks are filtered by domain name" do
    c1 = create(:check, user: @user, domain: "abc")
    c2 = create(:check, user: @user, domain: "bcde")
    create(:check, user: @user, domain: "hijk")

    get checks_path(by_domain: "bc")
    assert_equal [c1, c2], current_checks

    get checks_path(by_domain: "klm")
    assert_empty current_checks
  end

  test "checks are paginated" do
    create_list(:check, 40, user: @user)

    get checks_path
    assert_equal 1, current_checks.current_page
    first_page = current_checks

    get checks_path(page: 2)
    assert_equal 2, current_checks.current_page
    assert_not_equal first_page, current_checks
  end

  test "checks are scoped to current user" do
    c1 = create(:check, user: @user)
    create(:check)

    get checks_path
    assert_equal [c1], current_checks
  end

  def current_checks
    @controller.instance_variable_get("@checks")
  end
end
