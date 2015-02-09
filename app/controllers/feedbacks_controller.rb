class FeedbacksController < ApplicationController
  before_action :set_course!

  def index
    @members = @course.members
    @periods = @course.feedback_periods
    @feedbacks = Feedback.
      where(user: @members).
      each_with_object({}) do |f,h|
        h[ [f.member_id, f.feedback_period_id] ] = f
      end
  end

  def create
    feedback = @course.feedbacks.create! create_params
    redirect_to new_course_feedback_comment(@course, feedback)
  end

private

  def set_course!
    @course = Course.find params[:course_id]
  end

  def create_params
    params.permit(:user_id, :period_id)
  end
end
