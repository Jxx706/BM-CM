class AddNodeIdToReports < ActiveRecord::Migration
  def change
    add_column :reports, :node_id, :integer
  end
end
