class AddHashAttributesToFlows < ActiveRecord::Migration
  def change
    add_column :flows, :hash_attributes, :text
  end
end
