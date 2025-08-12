class AddRecipientPhoneNumberIdToConversationsAndUserChatbotInteractions < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :recipient_phone_number_id, :string
    add_column :user_chatbot_interactions, :recipient_phone_number_id, :string
  end
end
