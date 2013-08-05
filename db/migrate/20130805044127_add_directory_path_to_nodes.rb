class AddDirectoryPathToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :directory_path, :string
  end
end
