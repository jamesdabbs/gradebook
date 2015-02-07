class SetColumnDefaults < ActiveRecord::Migration
  def change
    TeamMembership.where(user_id: nil).find_each &:delete

    change_column :assignments, :title, :string, null: false, default: ''
    change_column :assignments, :body, :string, null: false, default: ''
    add_index :assignments, :team_id

    change_column :comments, :solution_id, :integer, null: false
    change_column :comments, :user_id, :integer, null: false
    change_column :comments, :remote_id, :integer, null: false
    change_column :comments, :body, :text, null: false
    remove_column :comments, :updated_at, :datetime

    change_column :solutions, :assignment_id, :integer, null: false
    change_column :solutions, :user_id, :integer, null: false
    change_column :solutions, :repo, :string, null: false
    change_column :solutions, :reviewed, :boolean, null: false, default: false

    change_column :team_memberships, :team_id, :integer, null: false
    change_column :team_memberships, :user_id, :integer, null: false

    remove_index :users, :email
    remove_index :users, :reset_password_token
    remove_column :users, :encrypted_password, :string
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    add_index :users, :github_username
  end
end
