class CreateFeedbackPeriods < ActiveRecord::Migration
  def change
    create_table :feedback_periods do |t|
      t.integer :course_id, null: false
      t.integer :start_week, null: false
      t.integer :end_week, null: false
    end
  end
end
