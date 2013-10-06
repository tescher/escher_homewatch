class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :sensor_id
      t.string :controller
      t.string :content

      t.timestamps
    end
  end
end
