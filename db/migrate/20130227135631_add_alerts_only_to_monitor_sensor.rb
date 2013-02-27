class AddAlertsOnlyToMonitorSensor < ActiveRecord::Migration
  def change
    add_column :monitor_sensors, :alerts_only, :boolean
  end
end
