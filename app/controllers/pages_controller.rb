# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class PagesController < ApplicationController
  def home
    redirect_to checks_path if user_signed_in?
  end
end
