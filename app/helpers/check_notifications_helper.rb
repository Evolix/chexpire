# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module CheckNotificationsHelper
  def recipient_col_class
    many_channels_available? ? "col-md-7" : "col-md-9"
  end
end
