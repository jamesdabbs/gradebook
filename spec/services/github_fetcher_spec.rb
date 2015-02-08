require 'rails_helper'

describe GithubFetcher do
  before :each do
    @client = double "client", {
      organization:        double("organization", id: 3),
      organization_teams: [double("team", id: 5, name: "team")],
      repo:                double("repo", id: 7)
    }
    @gh = GithubFetcher.new @client
  end

  it "can flesh out course data" do
    course = OpenStruct.new team_name: "team"
    @gh.fetch_course_data course

    expect(course.organization_id).to eq 3
    expect(course.team_id).to eq 5
    expect(course.repo_id).to eq 7
  end
end
