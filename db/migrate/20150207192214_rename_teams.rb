class RenameTeams < ActiveRecord::Migration
  def change
    rename_table :teams, :courses
  end
end
