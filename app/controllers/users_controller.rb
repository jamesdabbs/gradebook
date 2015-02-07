class UsersController < ApplicationController
  def show
    @user = User.find params[:id]
    @solutions = @user.solutions.
      includes(:assignment, comments: :user).
      order("assignments.due_at desc")
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update update_params
      redirect_to :back, notice: "Account updated"
    else
      render :edit
    end
  end

private

  def update_params
    params.require(:user).permit(:time_zone, :active_course_id)
  end
end
