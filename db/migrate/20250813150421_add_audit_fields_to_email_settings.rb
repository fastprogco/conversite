class AddAuditFieldsToEmailSettings < ActiveRecord::Migration[7.1]
  def change
    add_reference :email_settings, :added_by, foreign_key: { to_table: :users }, type: :bigint, null: false

    add_reference :email_settings, :edited_by, foreign_key: { to_table: :users }, type: :bigint, null: true

    add_reference :email_settings, :deleted_by, foreign_key: { to_table: :users }, type: :bigint, null: true
    add_column :email_settings, :is_deleted, :boolean, default: false
  end
end
