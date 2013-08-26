class AddMarkedAsDeletableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :marked_as_deletable, :boolean
  end
end
