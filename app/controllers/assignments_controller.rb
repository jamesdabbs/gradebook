class AssignmentsController < ApplicationController
  def index
    @assignments = if params[:all]
      Assignment.all
    else
      Assignment.where course: current_user.active_course
    end
  end

  def show
    @assignment = Assignment.find params[:id]
    @solutions = @assignment.solutions.includes(:user).reject { |s| s.user.admin? }
  end

  def new
    @assignment = Assignment.new
    @assignment.due_at = tomorrow_at_nine_for current_user.time_zone
  end

  def create
    @assignment = Assignment.new create_params
    @assignment.course = current_user.active_course
    @assignment.sync_from_gist! octoclient
    if @assignment.save
      redirect_to @assignment, success: 'Assignment created'
    else
      render :new
    end
  end

  def edit
    @assignment = Assignment.find params[:id]
  end

  def update
    @assignment = Assignment.find params[:id]
    if @assignment.update update_params
      @assignment.sync_issues!
      redirect @assignment, success: 'Assignment updated'
    else
      render :edit
    end
  end

  def assign
    assignment = Assignment.find params[:id]
    course = if params[:course_id]
      Course.find params[:course_id]
    else
      current_user.active_course
    end
    team.assign! octoclient, assignment
    redirect_to :back, success: 'Assigned issues'
  end

  private

  def create_params
    params.require(:assignment).permit :gist_id, :due_at
  end

  def tomorrow_at_nine_for tz
    tm = 1.day.from_now
    DateTime.new tm.year, tm.month, tm.day, 9, 0, 0, tz
  end
end
