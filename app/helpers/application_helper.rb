module ApplicationHelper
  def format_utc(time, format: :default)
    l(time.utc, format: format)
  end

  def available_locales_collection
    I18n.available_locales.map { |k| [t("shared.locales.#{k}"), k]}
  end
end
