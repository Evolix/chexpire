# frozen_string_literal: true

module ChecksHelper
  def check_row_class(check)
    expiry_date = check.domain_expires_at

    return unless expiry_date.present?

    return "table-danger" if expiry_date <= 3.days.from_now
    return "table-warning" if expiry_date < 1.month.from_now
  end

  def checks_sort_links(field)
    %i[asc desc].map { |direction|
      checks_sort_link(field, direction)
    }.join
  end

  def checks_sort_link(field, direction)
    classes = "btn btn-light btn-sm mx-1 mx-1 px-1 py-0"
    sort = [field, direction]

    icon = direction == :asc ? "chevron-up" : "chevron-down"
    html = Octicons::Octicon.new(icon).to_svg.html_safe

    sort_path = checks_path(current_criterias.merge(sort: sort.join("_")))
    link_to_unless sort == current_sort, html, sort_path, class: classes do
      content_tag(:span, html, class: classes + " active")
    end
  end

  def check_in_error(check)
    content_tag(
      :span,
      Octicons::Octicon.new("alert", class: "ml-1").to_svg.html_safe,
      class: "in-error text-danger",
      data: {
        toggle: "tooltip",
        placement: "bottom",
        title: check_last_success_title(check)
      })
  end

  def current_criterias
    current_scopes.merge(sort: params[:sort])
  end

  def scoped_with?(scope)
    name, value = scope.first
    scope_value = current_scopes[name]
    scope_value = scope_value.to_sym if scope_value.respond_to?(:to_sym)

    scope_value == value
  end

  def check_button_criterias(scope)
    if scoped_with?(scope)
      current_criterias.except(scope.keys.first)
    else
      current_criterias.merge(scope)
    end
  end

  def check_button_scope_class(scope = nil)
    "btn btn-sm " + if scope && scoped_with?(scope)
                      "btn-info active"
                    else
                      "btn-outline-info"
                    end
  end

  def check_last_success_title(check)
    return t(".never_succeeded") if check.last_success_at.nil?

    t(".days_from_last_success", count: check.days_from_last_success)
  end
end
