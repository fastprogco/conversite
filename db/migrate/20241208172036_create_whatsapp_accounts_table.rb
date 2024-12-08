class CreateWhatsappAccountsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :whatsapp_accounts do |t|
      t.string :name
      t.string :whatsapp_mobile_number
      t.string :app_id
      t.string :phone_number_id
      t.string :whatsapp_business_account_id
      t.string :token
      t.string :webhook_version

      t.references :added_by, foreign_key: { to_table: :users }, null: true
      t.references :edited_by, foreign_key: { to_table: :users }, null: true
      t.boolean :is_deleted, default: false
      t.references :deleted_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end
  end
end
