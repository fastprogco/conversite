class CreateUserChatbotInteractions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_chatbot_interactions do |t|
      t.references :chatbot_step, null: false, foreign_key: true
      t.string :clicked_button_id
      t.string :mobile_number

      t.timestamps
    end
  end
end
