class AddAdminIdToTeams < ActiveRecord::Migration
  def change
    remove_column :teams, :user_id, :integer
    add_column :teams, :admin_id, :integer
  end
end
