class CoursesController < ApplicationController
  def index
    @courses = Course.all
  end

  def show
    @course = Course.find params[:id]

    @members = @course.members.students.to_a
    @members.shuffle! if params[:shuffle]

    @solutions = Solution.where(user: @course.members).
      map { |s| [[s.assignment_id, s.user_id], s] }.to_h
    @assignments = Assignment.find @solutions.keys.map(&:first).uniq.sort
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new create_params
    @course.admin = current_user
    @course.fetch_from_github! octoclient
    if @course.save
      @course.sync! octoclient
      @course.create_issue_tracking_webhook! octoclient if Rails.env.production?
      redirect_to @course, success: 'Course created'
    else
      render :new
    end
  end

  def sync
    course = Course.find params[:id]
    course.sync! octoclient
    course.check_assignments! octoclient
    redirect_to :back
  end

  private

  def create_params
    params.require(:course).permit :organization, :name, :issues_repo
  end
end
