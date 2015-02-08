class FeedbackPeriod < ActiveRecord::Base
  belongs_to :course

  validates_presence_of :course, :start_week, :end_week

  def self.create_for! course
    1.upto(12).each_slice 2 do |start_week, end_week|
      course.
        feedback_periods.
        where(start_week: start_week, end_week: end_week).
        first_or_create!
    end
  end

  def week_range
    "#{start_week}-#{end_week}"
  end

  def date_range
    course_start = course.start_date
    period_start = course_start + (start_week - 1).weeks
    period_end   = course_start + end_week.weeks
    period_start ... period_end
  end

  def assignments
    course.assignments.where due_at: date_range
  end
end
