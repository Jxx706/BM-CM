class RemoveTypeFromFlows < ActiveRecord::Migration
  def up
    remove_column :flows, :type
  end

  def down
    add_column :flows, :type, :string
  end
end
