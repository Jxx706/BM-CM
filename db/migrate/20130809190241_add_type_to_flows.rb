class AddTypeToFlows < ActiveRecord::Migration
  def change
    add_column :flows, :type, :string
  end
end
