class RemoveFilePathFromFlows < ActiveRecord::Migration
  def up
    remove_column :flows, :file_path
  end

  def down
    add_column :flows, :file_path, :string
  end
end
