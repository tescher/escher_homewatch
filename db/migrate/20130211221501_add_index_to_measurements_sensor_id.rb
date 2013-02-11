class AddIndexToMeasurementsSensorId < ActiveRecord::Migration
  def change
    add_index :measurements, :sensor_id
  end
end
