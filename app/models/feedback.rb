class Feedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :feedback_period
  belongs_to :course

  validates_presence_of :user, :feedback_period, :course
end
