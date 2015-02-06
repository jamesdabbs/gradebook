class UsersController < ApplicationController
  def show
    @user = User.find params[:id]
    @solutions = @user.solutions.
      includes(:assignment, comments: :user).
      order("assignments.due_at desc")
  end
end
