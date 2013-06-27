class AddNodeNameToFlow < ActiveRecord::Migration
  def change
    add_column :flows, :node_name, :string
  end
end
