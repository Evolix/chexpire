class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.chexpire.fetch("mailer_default_from")
  layout "mailer"
end
