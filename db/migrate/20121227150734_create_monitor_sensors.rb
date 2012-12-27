class CreateMonitorSensors < ActiveRecord::Migration
  def change
    create_table :monitor_sensors do |t|
      t.integer :sensor_id
      t.integer :monitor_window_id
      t.string :legend
      t.string :color

      t.timestamps
    end
  end
end