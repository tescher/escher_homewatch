class AddPositionToMonitorWindows < ActiveRecord::Migration
  def change
    add_column :monitor_windows, :position, :integer
  end
end
