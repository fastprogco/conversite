class AddFieldsToChatbotButtonReplies < ActiveRecord::Migration[7.1]
  def change

    change_table :chatbot_button_replies do |t|
      t.references :added_by, foreign_key: { to_table: :users }, null: true
      t.datetime :added_on
      t.references :edited_by, foreign_key: { to_table: :users }, null: true
      t.datetime :edited_on
      t.boolean :is_deleted, default: false
      t.references :deleted_by, foreign_key: { to_table: :users }, null: true
    end
  end
end
