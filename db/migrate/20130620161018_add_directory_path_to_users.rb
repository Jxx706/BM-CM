class AddDirectoryPathToUsers < ActiveRecord::Migration
  def change
    add_column :users, :directory_path, :string
  end
end
