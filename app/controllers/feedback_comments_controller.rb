class FeedbackCommentsController < ApplicationController
  before_action :set_scope!

  def new
    @assignments = @period.assignments
    @solutions = @user.solutions.
      where(assignment: @assignments).
      includes(:assignment, :comments => :user).
      map { |s| [s.assignment_id, s] }.to_h
  end

private

  def set_scope!
    @course = Course.find params[:course_id]
    @feedback = course.feedbacks.find params[:feedback_id]
    @user = @feedback.user
    @period = @feedback.period
  end
end
