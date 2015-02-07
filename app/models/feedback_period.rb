class FeedbackPeriod < ActiveRecord::Base
  belongs_to :course

  validates_presence_of :course, :start_week, :end_week
end
