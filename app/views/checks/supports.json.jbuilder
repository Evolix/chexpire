# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

json.check do
  json.supported @check.supported?
  json.domain normalize_domain(@check.domain)
end
