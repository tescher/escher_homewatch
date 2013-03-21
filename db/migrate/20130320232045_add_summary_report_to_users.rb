class AddSummaryReportToUsers < ActiveRecord::Migration
  def change
    add_column :users, :summary_report, :boolean, :default => true
  end
end
