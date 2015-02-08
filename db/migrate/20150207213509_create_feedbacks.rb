class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.integer :course_id, null: false
      t.integer :feedback_period_id, null: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end
  end
end
