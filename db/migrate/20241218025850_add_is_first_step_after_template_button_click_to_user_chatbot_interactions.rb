class AddIsFirstStepAfterTemplateButtonClickToUserChatbotInteractions < ActiveRecord::Migration[7.1]
  def change
    add_column :user_chatbot_interactions, :is_first_step_after_template_button_click, :boolean, default: false
  end
end
