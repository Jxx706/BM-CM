class CreateFlows < ActiveRecord::Migration
  def change
    create_table :flows do |t|
      t.string :name
      t.string :file_path

      t.timestamps
    end
  end
end
