class RemoveHtmlUrlFromSolutions < ActiveRecord::Migration
  def change
    remove_column :solutions, :html_url, :string
  end
end
