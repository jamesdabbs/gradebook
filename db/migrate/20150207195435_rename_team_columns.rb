class RenameTeamColumns < ActiveRecord::Migration
  def change
    rename_column :assignments, :team_id, :course_id
    rename_column :courses, :name, :team_name
    rename_column :team_memberships, :team_id, :course_id
    rename_column :users, :active_team_id, :active_course_id
  end
end
