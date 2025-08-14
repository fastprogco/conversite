class AddUserReferencesToEmailTemplates < ActiveRecord::Migration[7.1]
  def change
    add_reference :email_templates, :added_by,  null: false, foreign_key: { to_table: :users }, type: :bigint
    add_reference :email_templates, :edited_by, foreign_key: { to_table: :users }, type: :bigint, null: true
    add_reference :email_templates, :deleted_by, foreign_key: { to_table: :users }, type: :bigint, null: true
  end
end
