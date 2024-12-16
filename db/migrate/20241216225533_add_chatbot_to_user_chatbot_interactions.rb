class AddChatbotToUserChatbotInteractions < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_chatbot_interactions, :chatbot, null: false, foreign_key: true
  end
end
