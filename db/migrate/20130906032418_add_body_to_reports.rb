class AddBodyToReports < ActiveRecord::Migration
  def change
    add_column :reports, :body, :string
  end
end
