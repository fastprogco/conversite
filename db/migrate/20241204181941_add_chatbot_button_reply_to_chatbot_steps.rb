class AddChatbotButtonReplyToChatbotSteps < ActiveRecord::Migration[7.1]
  def change
    add_reference :chatbot_steps, :chatbot_button_reply, null: true, foreign_key: true
  end
end
