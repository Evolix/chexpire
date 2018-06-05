module NotificationsHelper
  def many_channels_available?
    Notification.channels.many?
  end

  def recipient_col_class
    many_channels_available? ? "col-md-7" : "col-md-9"
  end
end
