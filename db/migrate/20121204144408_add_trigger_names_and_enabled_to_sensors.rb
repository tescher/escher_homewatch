class AddTriggerNamesAndEnabledToSensors < ActiveRecord::Migration
  def change
    add_column :sensors, :trigger_lower_name, :string
    add_column :sensors, :trigger_upper_name, :string
  end
end
