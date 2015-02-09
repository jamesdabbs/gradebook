class CreateFeedbackComments < ActiveRecord::Migration
  def change
    create_table :feedback_comments do |t|
      t.integer :feedback_id, null: false
      t.integer :commenter_id, null: false
      t.text    :body, null: false
      t.integer :score, null: false

      t.timestamps null: false
    end
  end
end
