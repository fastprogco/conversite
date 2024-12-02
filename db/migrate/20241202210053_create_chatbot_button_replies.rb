class CreateChatbotButtonReplies < ActiveRecord::Migration[7.1]
  def change
    create_table :chatbot_button_replies do |t|
      t.references :chatbot, null: false, foreign_key: true
      t.references :chatbot_step, null: false, foreign_key: true
      t.integer :action_type_id
      t.integer :order
      t.string :title

      t.timestamps
    end
  end
end
