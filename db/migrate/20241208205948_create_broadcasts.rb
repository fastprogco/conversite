class CreateBroadcasts < ActiveRecord::Migration[7.1]
  def change
    create_table :broadcasts do |t|
      t.string :name
      t.references :whatsapp_account, foreign_key: true
      t.references :template, foreign_key: true
      t.references :master_segment, foreign_key: true
      t.integer :timing, null: false 
      t.references :added_by, foreign_key: { to_table: :users }, null: true
      t.references :edited_by, foreign_key: { to_table: :users }, null: true
      t.boolean :is_deleted, default: false
      t.references :deleted_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end
  end
end
