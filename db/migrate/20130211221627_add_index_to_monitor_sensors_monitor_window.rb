class AddIndexToMonitorSensorsMonitorWindow < ActiveRecord::Migration
  def change
    add_index :monitor_sensors, :monitor_window_id
  end
end
