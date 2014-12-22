class AddFieldsToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :IP_address, :string
    add_column :logs, :restart_location, :string
  end
end
