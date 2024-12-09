class AddNameToBroadcastReports < ActiveRecord::Migration[7.1]
  def change
    add_column :broadcast_reports, :name, :string
  end
end
