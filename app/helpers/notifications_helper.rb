module NotificationsHelper
  def many_channels_available?
    Notification.channels.many?
  end

  def notification_variable_col_class
    many_channels_available? ? "col-md-4" : "col-md-5"
  end
end
