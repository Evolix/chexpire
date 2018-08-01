# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module UsersHelper
  # Inject a devise template inside a same container
  # while translation form keys are still valid
  # (original partial scope is preserved)
  def devise_form_container
    content_for(:devise_form_content) do
      yield
    end

    render "shared/devise_form_container"
  end
end
