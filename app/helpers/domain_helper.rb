# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module DomainHelper
  def normalize_domain(str)
    str.strip.downcase
  end

  def tld(str)
    parts = normalize_domain(str).split(".")
    fail ArgumentError unless parts.size >= 2

    ".#{parts.last}"
  end
end
