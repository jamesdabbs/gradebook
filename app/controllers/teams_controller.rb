class TeamsController < ApplicationController
  def index
    @teams = Team.all
  end

  def show
    @team = Team.find params[:id]

    @members = @team.members.reject &:admin?
    @members.shuffle! if params[:shuffle]

    @solutions = Solution.where(user: @team.members).
      map { |s| [[s.assignment_id, s.user_id], s] }.to_h
    @assignments = Assignment.find @solutions.keys.map(&:first).uniq.sort
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new create_params
    @team.fetch_from_github! octoclient
    if @team.save
      @team.sync! octoclient
      @team.create_issue_tracking_webhook! octoclient if Rails.env.production?
      redirect_to @team, success: 'Team created'
    else
      render :new
    end
  end

  def activate
    current_user.update_attribute :active_team_id, params[:id]
    redirect_to :back
  end

  def sync
    team = Team.find params[:id]
    team.sync! octoclient
    team.check_assignments! octoclient
    redirect_to :back
  end

  private

  def create_params
    params.require(:team).permit :organization, :name, :issues_repo
  end
end
