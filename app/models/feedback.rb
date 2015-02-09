class Feedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :feedback_period
  belongs_to :course

  has_many :comments, class_name: "FeedbackComment"

  validates_presence_of :user, :feedback_period, :course
end
