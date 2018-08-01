# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module ChexpireAssertions
  def assert_just_now(expected)
    assert_in_delta expected.to_i, Time.now.to_i, 1.0
  end

  def assert_permit(user, record, action)
    msg = "User #{user.inspect} should be permitted to #{action} #{record}, but isn't permitted"
    assert policy_permit(user, record, action), msg
  end

  def refute_permit(user, record, action)
    msg = "User #{user.inspect} should NOT be permitted to #{action} #{record}, but is permitted"
    refute policy_permit(user, record, action), msg
  end

  private

  def policy_permit(user, record, action)
    test_name = self.class.ancestors.select { |a| a.to_s.match(/PolicyTest/) }.first
    klass = test_name.to_s.gsub(/Test/, "")
    klass.constantize.new(user, record).public_send("#{action}?")
  end
end
