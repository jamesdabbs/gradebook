class Team < ActiveRecord::Base
  has_many :memberships, class_name: 'TeamMembership', dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :assignments

  validates_presence_of :organization, :name, :issues_repo
  validates_uniqueness_of :name, scope: :organization

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

  def fetch_from_github! octoclient
    begin
      self.organization_id = octoclient.organization(organization).id
    rescue Octokit::NotFound => e
      errors.add :organization, "not found on Github"
    end

    begin
      gh_team = octoclient.organization_teams(organization).find do |t|
        t.name.downcase == name.downcase
      end || raise(Octokit::NotFound)
      self.team_id = gh_team.id
    rescue Octokit::NotFound => e
      self.team_id = nil
    end

    begin
      self.repo_id = octoclient.repo("#{organization}/#{issues_repo}").id
    rescue Octokit::NotFound => e
      self.repo_id = nil
    end
  end

  def title
    "#{organization}/#{name}" if organization.present? && name.present?
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
      events: ['issues'],
      active: true
    }
  end

  def sync! octoclient
    octoclient.team_members(team_id).each do |member|
      user = User.where(github_username: member.login).first_or_create! do |u|
        gh_user = octoclient.user member.login
        u.name  = gh_user.name || gh_user.login
      end
      members << user unless members.include? user
    end
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
        solution.status = :assigned
      end
    end
  end
end
