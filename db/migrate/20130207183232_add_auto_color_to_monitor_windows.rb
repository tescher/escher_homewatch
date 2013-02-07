class AddAutoColorToMonitorWindows < ActiveRecord::Migration
  def change
    add_column :monitor_windows, :background_color_auto, :boolean
  end
end
