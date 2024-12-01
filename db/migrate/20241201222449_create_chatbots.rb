class CreateChatbots < ActiveRecord::Migration[7.1]
  def change
    create_table :chatbots do |t|
      t.string :name
      t.text :description
      t.boolean :is_deleted, default: false
      t.references :deleted_by, foreign_key: { to_table: :users }, null: true
      t.references :created_by, foreign_key: { to_table: :users }, null: true
      t.references :edited_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end
  end
end
