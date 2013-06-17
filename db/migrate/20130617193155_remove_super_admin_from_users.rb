class RemoveSuperAdminFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :super_admin?
  end

  def down
    add_column :users, :super_admin?, :boolean
  end
end
