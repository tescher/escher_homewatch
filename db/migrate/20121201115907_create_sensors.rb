class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.string :name
      t.integer :sensor_type_id
      t.integer :user_id
      t.string :group
      t.string :controller
      t.integer :addressH
      t.integer :addressL
      t.float :offset
      t.float :scale
      t.integer :interval
      t.float :trigger_upper_limit
      t.float :trigger_lower_limit
      t.integer :trigger_delay
      t.string :trigger_email
      t.boolean :trigger_enabled
      t.boolean :absence_alert

      t.timestamps
    end
  end
end
