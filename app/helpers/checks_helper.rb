module ChecksHelper
  def check_kind_label(check)
    check.kind.upcase
  end

  def check_row_class(check)
    expiry_date = check.domain_expires_at

    return unless expiry_date.present?

    return "table-danger" if expiry_date <= 2.weeks.from_now
    return "table-warning" if expiry_date <= 30.days.from_now
  end
end
