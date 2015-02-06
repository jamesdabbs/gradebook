class AddReviewedToSolutions < ActiveRecord::Migration
  def change
    add_column :solutions, :reviewed, :boolean
    remove_column :solutions, :status, :string
  end
end
