class AddFieldsToChatbotSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :chatbot_steps, :end_chabot, :boolean, default: false
    add_column :chatbot_steps, :end_chabot_reply, :string
    add_column :chatbot_steps, :has_go_back_to_main, :boolean, default: false
  end
end
