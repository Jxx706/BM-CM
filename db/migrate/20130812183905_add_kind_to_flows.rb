class AddKindToFlows < ActiveRecord::Migration
  def change
    add_column :flows, :kind, :string
  end
end
