module ApplicationHelper
  def format_utc(time, format: :default)
    l(time.utc, format: format)
  end
end
