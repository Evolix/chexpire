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
