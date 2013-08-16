class AddIndexToFlowsName < ActiveRecord::Migration
  def change
  	add_index :flows, :name, :unique => true
  end
end
