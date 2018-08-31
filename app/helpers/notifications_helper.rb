module NotificationsHelper
  def many_channels_available?
    Notification.channels.many?
  end
end
