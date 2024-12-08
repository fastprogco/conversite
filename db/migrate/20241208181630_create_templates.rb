class CreateTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :templates do |t|
      t.string :name
      t.string :meta_template_name
      t.string :language
      t.string :component
      t.references :added_by, foreign_key: { to_table: :users }, null: true
      t.references :edited_by, foreign_key: { to_table: :users }, null: true
      t.boolean :is_deleted, default: false
      t.references :deleted_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end
  end
end
