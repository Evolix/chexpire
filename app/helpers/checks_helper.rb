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

  def checks_sort_links(field)
    current_sort_str = current_sort.to_a.join("_")

    %i[asc desc].map { |direction|
      sort = "#{field}_#{direction}"

      icon = direction == :asc ? "chevron-up" : "chevron-down"
      html = Octicons::Octicon.new(icon).to_svg.html_safe

      filter_params = current_criterias.merge(sort: sort)
      link_to_unless sort == current_sort_str, html, checks_path(filter_params)
    }.join
  end

  def current_criterias
    current_scopes.merge(sort: params[:sort])
  end
end
