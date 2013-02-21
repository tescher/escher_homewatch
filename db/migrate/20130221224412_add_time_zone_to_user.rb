class AddTimeZoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :time_zone, :string, :default => DEFAULT_TIME_ZONE
  end
end
