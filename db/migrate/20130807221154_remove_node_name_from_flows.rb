class RemoveNodeNameFromFlows < ActiveRecord::Migration
  def up
    remove_column :flows, :node_name
  end

  def down
    add_column :flows, :node_name, :string
  end
end
