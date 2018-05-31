# == Schema Information
#
# Table name: check_logs
#
#  id              :bigint(8)        not null, primary key
#  error           :text(65535)
#  exit_status     :integer
#  parsed_response :text(65535)
#  raw_response    :text(65535)
#  status          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  check_id        :bigint(8)
#
# Indexes
#
#  index_check_logs_on_check_id  (check_id)
#
# Foreign Keys
#
#  fk_rails_...  (check_id => checks.id)
#

require "test_helper"

class CheckLogTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
