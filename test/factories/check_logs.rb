# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

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

FactoryBot.define do
  factory :check_log do
    check
    status :pending
    exit_status nil
    parsed_response nil
    raw_response nil
  end
end
