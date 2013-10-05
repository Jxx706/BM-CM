class RemoveBodyFromReports < ActiveRecord::Migration
  def up
    remove_column :reports, :body
  end

  def down
    add_column :reports, :body, :string
  end
end
