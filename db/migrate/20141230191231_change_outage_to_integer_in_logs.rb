class ChangeOutageToIntegerInLogs < ActiveRecord::Migration
  def up
      remove_column :logs, :outage
      add_column :logs, :outage, :integer
  end

  def down
      remove_column :logs, :outage
      add_column :logs, :outage, :datetime
  end
end
