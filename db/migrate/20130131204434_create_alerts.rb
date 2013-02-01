class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.integer :sensor_id
      t.float :value
      t.float :limit
      t.string :email

      t.timestamps
    end
  end
end
