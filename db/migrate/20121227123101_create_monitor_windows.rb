class CreateMonitorWindows < ActiveRecord::Migration
  def change
    create_table :monitor_windows do |t|
      t.enum :monitor_type
      t.string :name
      t.integer :user_id
      t.integer :y_axis_min
      t.boolean :y_axis_min_auto
      t.integer :y_axis_max
      t.boolean :y_axis_max_auto
      t.integer :x_axis_days
      t.boolean :x_axis_auto
      t.string :background_color
      t.boolean :legend
      t.boolean :public
      t.string :url
      t.string :width

      t.timestamps
    end
  end
end
