class AddScheduledAtToBroadcasts < ActiveRecord::Migration[7.1]
  def change
    add_column :broadcasts, :scheduled_at, :datetime
  end
end
