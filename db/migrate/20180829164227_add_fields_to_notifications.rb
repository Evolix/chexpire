# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class AddFieldsToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_reference :notifications, :user, foreign_key: true
    add_column :notifications, :label, :string
    add_column :notifications, :checks_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        # first set user & label for *all* notifications
        Notification.find_each do |notification|
          check = Check.find(notification.check_id) # check relation does not exist anymore

          notification.user_id = check.user_id
          notification.label = "#{notification.recipient} (#{notification.interval})"
          notification.save!
        end

        # then build the equivalent check notification
        Notification.find_each do |notification|
          assoc_notification = Notification.where(
            user_id: notification.user_id,
            recipient: notification.recipient,
            interval: notification.interval,
          ).order(checks_count: :desc).limit(1).first

          CheckNotification.create!(
            check_id: notification.check_id,
            notification: assoc_notification,
            status: notification.status,
            sent_at: notification.sent_at
          )
        end

        # last delete duplicate notification templates not used
        Notification.where(checks_count: 0).destroy_all
      end
    end
  end
end
