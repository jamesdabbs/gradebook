class GithubFetcher
  def initialize client
    @client = client
  end

  def fetch_course_data course
    course.organization_id = organization_id course.organization
    course.team_id = team_id course.organization, course.team_name
    course.repo_id = repo_id course.organization, course.issues_repo
  rescue => e
    binding.pry
  end

  def sync_course course
    remote_members = @client.team_members course.team_id
    delete_old_memberships course, remote_members
    create_new_memberships course, remote_members
  end

  def delete_old_memberships course, remote_members
    current = Set.new remote_members.map &:login
    course.memberships.includes(:user).each do |ms|
      ms.delete unless current.include? ms.user.github_username
    end
  end

  def create_new_memberships course, remote_members
    remote_members.each do |member|
      user = User.where(github_username: member.login).first_or_create! do |u|
        gh_user = @client.user member.login
        u.name  = gh_user.name || gh_user.login
      end
      course.add_member user
    end
  end

  def organization_id org_name
    @client.organization(org_name).id
  rescue Octokit::NotFound => e
    nil
  end

  def team_id org_name, team_name
    teams = @client.organization_teams org_name
    team  = teams.find { |t| t.name.downcase == team_name.downcase }
    team.try :id
  rescue Octokit::NotFound => e
    nil
  end

  def repo_id org_name, repo_name
    @client.repo("#{org_name}/#{repo_name}").id
  rescue Octokit::NotFound => e
    nil
  end
end
