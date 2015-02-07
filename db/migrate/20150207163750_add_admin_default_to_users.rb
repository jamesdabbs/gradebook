class AddAdminDefaultToUsers < ActiveRecord::Migration
  def up
    change_column :users, :admin, :boolean, default: false
    User.where(admin: nil).update_all(admin: false)
  end

  def down
    change_column :users, :admin, :boolean, default: nil
  end
end
