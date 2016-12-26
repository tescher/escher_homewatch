class AddPauseUntilToSensor < ActiveRecord::Migration
  def change
    add_column :sensors, :pause_until, :datetime
  end
end
