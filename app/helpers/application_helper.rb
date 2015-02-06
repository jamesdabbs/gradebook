module ApplicationHelper
  def self.format_datetime dt
    # TODO: make this more flexible
    dt.in_time_zone("EST").strftime "%b %d @ %I:%M%P"
  end

  def format_datetime dt
    # :shipit:
    ApplicationHelper.format_datetime dt
  end

  def time_relative_to_due_at due_at, submitted
    if due_at - 1.day < submitted && submitted <= due_at
      submitted.in_time_zone("EST").strftime "%I:%M%P"
    else
      format_datetime submitted
    end
  end

  def fluid_layout!
    @fluid_layout = true
  end

  def markdown text
    GitHub::Markup.render('README.md', text).html_safe
  end

  def icon name
    "<i class='glyphicon glyphicon-#{name}'></i>".html_safe
  end

  def flash_class name
    # Translate rails conventions to bootstrap conventions
    case name.to_sym
    when :notice
      :success
    when :alert
      :danger
    else
      name
    end
  end
end
