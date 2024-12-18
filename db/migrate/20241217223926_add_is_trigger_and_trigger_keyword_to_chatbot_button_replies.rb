class AddIsTriggerAndTriggerKeywordToChatbotButtonReplies < ActiveRecord::Migration[7.1]
  def change
    add_column :chatbot_button_replies, :is_trigger, :boolean, default: false, null: false
    add_column :chatbot_button_replies, :trigger_keyword, :string
  end
end
