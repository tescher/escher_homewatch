class AddAutoColorToMonitorSensors < ActiveRecord::Migration
  def change
    add_column :monitor_sensors, :color_auto, :boolean
  end
end
