class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :solution_id
      t.integer :user_id
      t.integer :remote_id
      t.text :body

      t.timestamps null: false
    end
  end
end
