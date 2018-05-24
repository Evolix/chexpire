require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home loads without error" do
    get root_path
    assert_response :success
  end
end
