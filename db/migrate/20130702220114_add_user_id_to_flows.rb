class AddUserIdToFlows < ActiveRecord::Migration
  def change
    add_column :flows, :user_id, :integer
    add_index :flows, [:user_id, :created_at]
  end
end
