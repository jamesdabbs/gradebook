class AddGithubDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_data, :text
  end
end
