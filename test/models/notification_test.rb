# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

# == Schema Information
#
# Table name: notifications
#
#  id         :bigint(8)        not null, primary key
#  channel    :integer          default("email"), not null
#  interval   :integer          not null
#  recipient  :string(255)      not null
#  sent_at    :datetime
#  status     :integer          default("pending"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  check_id   :bigint(8)
#
# Indexes
#
#  index_notifications_on_check_id  (check_id)
#
# Foreign Keys
#
#  fk_rails_...  (check_id => checks.id)
#

require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
