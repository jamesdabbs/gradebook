module ApplicationHelper
  def self.format_datetime dt, zone
    dt.in_time_zone(zone).strftime "%b %d @ %I:%M%P"
  end

  def format_datetime dt, zone=nil
    zone ||= current_user.time_zone
    ApplicationHelper.format_datetime dt, zone
  end

  def time_relative_to_due_at due_at, submitted, zone=nil
    zone ||= current_user.time_zone
    if due_at - 1.day < submitted && submitted <= due_at
      submitted.in_time_zone(zone).strftime "%I:%M%P"
    else
      format_datetime submitted
    end
  end

  def active_course
    current_user.try :active_course
  end

  def fluid_layout!
    @fluid_layout = true
  end

  def markdown text
    GitHub::Markup.render('README.md', text).html_safe
  end

  def github_link title, *args
    title = title.sub /^https?:\/\/github.com\//, ''
    title = title.sub /\.git$/, ''
    link_to title, *args
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
