class AddRawToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :raw, :float
  end
end
