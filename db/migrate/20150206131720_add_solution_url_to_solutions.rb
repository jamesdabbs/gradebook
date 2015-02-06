class AddSolutionUrlToSolutions < ActiveRecord::Migration
  def change
    add_column :solutions, :solution_url, :string
  end
end
