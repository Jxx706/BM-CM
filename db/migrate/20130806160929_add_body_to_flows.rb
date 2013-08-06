class AddBodyToFlows < ActiveRecord::Migration
  def change
    add_column :flows, :body, :string
  end
end
