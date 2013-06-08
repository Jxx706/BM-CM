class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :last_name
      t.string :email
      t.string :password
      t.boolean :super_admin?

      t.timestamps
    end
  end
end
