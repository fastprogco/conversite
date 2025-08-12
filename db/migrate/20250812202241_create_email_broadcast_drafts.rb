class CreateEmailBroadcastDrafts < ActiveRecord::Migration[7.1]
  def change
    create_table :email_broadcast_drafts do |t|
      t.string :subject

      t.timestamps
    end
  end
end
