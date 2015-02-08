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

  def new
    @user = User.find params[:user]
    @period = FeedbackPeriod.find params[:period]
    @assignments = @period.assignments
    @solutions = @user.solutions.
      where(assignment: @assignments).
      includes(:assignment).
      map { |s| [s.assignment_id, s] }.to_h
  end

private

  def set_course!
    @course = Course.find params[:course_id]
  end
end
