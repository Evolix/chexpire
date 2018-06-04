module ChexpireAssertions
  def assert_just_now(expected)
    assert_in_delta expected.to_i, Time.now.to_i, 1.0
  end
end
