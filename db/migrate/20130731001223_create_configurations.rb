class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.integer :node_id
      t.integer :flow_id

      t.timestamps
    end
  end
end
