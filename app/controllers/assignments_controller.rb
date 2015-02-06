class AssignmentsController < ApplicationController
  def index
    @assignments = if params[:all]
      Assignment.all
    else
      Assignment.where team: current_user.active_team
    end
  end

  def show
    @assignment = Assignment.find params[:id]
    @solutions = @assignment.solutions.includes(:user).reject { |s| s.user.admin? }
  end

  def new
    @assignment = Assignment.new
  end

  def create
    @assignment = Assignment.new create_params
    @assignment.team = current_user.active_team
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
    team = if params[:team_id]
      Team.find params[:team_id]
    else
      current_user.active_team
    end
    team.assign! octoclient, assignment
    redirect_to :back, success: 'Assigned issues'
  end

  private

  def create_params
    params.require(:assignment).permit :gist_id, :due_at
  end
end
