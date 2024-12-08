class CreateBroadcastReports < ActiveRecord::Migration[7.1]
  def change
    create_table :broadcast_reports do |t|
      t.references :broadcast, foreign_key: true
      t.string :broadcast_name
      t.string :mobile
      t.string :nationality
      t.datetime :sent_on
      t.datetime :delivered_on
      t.datetime :seen_on
      t.integer :message_status

      t.timestamps
    end
  end
end
