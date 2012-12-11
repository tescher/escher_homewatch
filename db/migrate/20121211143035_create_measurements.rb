class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.integer :sensor_id
      t.float :value

      t.timestamps
    end
  end
end
