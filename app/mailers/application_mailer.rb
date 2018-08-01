# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.chexpire.fetch("mailer_default_from")
  layout "mailer"
end
