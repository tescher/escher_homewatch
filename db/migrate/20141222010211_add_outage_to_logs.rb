class AddOutageToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :outage, :datetime
  end
end
