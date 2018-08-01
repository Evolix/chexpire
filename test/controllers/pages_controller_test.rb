# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home loads without error" do
    get root_path
    assert_response :success
  end
end
