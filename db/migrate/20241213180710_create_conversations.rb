class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.string :mobile_number
      t.text :details
      t.boolean :is_from_chat_bot

      t.timestamps
    end
  end
end
