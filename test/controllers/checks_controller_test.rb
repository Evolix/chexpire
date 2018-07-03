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
end
