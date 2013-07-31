class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :ip
      t.string :hostname
      t.string :domain
      t.string :fqdn

      t.timestamps
    end
  end
end
