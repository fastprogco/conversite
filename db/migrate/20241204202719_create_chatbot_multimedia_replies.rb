class CreateChatbotMultimediaReplies < ActiveRecord::Migration[7.1]
  def change
    create_table :chatbot_multimedia_replies do |t|
      t.references :chatbot, foreign_key: true
      t.references :chatbot_step, foreign_key: true
      t.integer :media_type_id
      t.integer :order
      t.text :text_body
      t.string :file_caption
      t.references :added_by, foreign_key: { to_table: :users }, null: true
      t.datetime :added_on
      t.references :edited_by, foreign_key: { to_table: :users }, null: true
      t.datetime :edited_on
      t.references :deleted_by, foreign_key: { to_table: :users }, null: true
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
