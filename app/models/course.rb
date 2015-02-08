class Course < ActiveRecord::Base
  belongs_to :admin, class_name: 'User'

  has_many :memberships, class_name: 'TeamMembership', dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :assignments

  has_many :feedback_periods

  validates_presence_of :admin, :organization, :team_name, :issues_repo, :start_date
  validates_uniqueness_of :team_name, scope: :organization

  validate :found_on_github
  def found_on_github
    {
      organization: organization_id,
      name:         team_id,
      issues_repo:  repo_id
    }.each do |input, fetched|
      errors.add input, "not found on Github" unless fetched.present?
    end
  end

  def title
    "#{organization}/#{team_name}" if organization.present? && team_name.present?
  end

  def fully_qualified_issues_repo
    "#{organization}/#{issues_repo}"
  end

  def create_issue_tracking_webhook! octoclient
    # TODO: should we generate and use a different secret for each hook / team?
    #   how do we look it up on receiving the hook?
    octoclient.create_hook "#{organization}/#{issues_repo}", "web", {
      url: Rails.application.routes.url_helpers.receive_solutions_hook_url,
      secret: ENV.fetch('GITHUB_WEBHOOK_SECRET'),
      content_type: 'json'
    }, {
      events: ['issues', 'issue_comment'],
      active: true
    }
  end

  def add_member user
    members << user unless members.include? user
  end

  def assign! octoclient, assignment
    members.each do |member|
      member.solutions.where(assignment: assignment).first_or_create! do |solution|
        issue = octoclient.open_issue(
          fully_qualified_issues_repo, assignment.title, assignment.as_issue,
          assignee: member.github_username, labels: 'homework'
        )
        solution.number = issue.number
        solution.repo   = fully_qualified_issues_repo
      end
    end
  end

  def check_assignments! octoclient
    assignments.find_each { |a| a.check! octoclient }
  end
end
