class CreateSensorTypes < ActiveRecord::Migration
  def change
    create_table :sensor_types do |t|
      t.string :name
      t.float :offset
      t.float :scale

      t.timestamps
    end
  end
end
