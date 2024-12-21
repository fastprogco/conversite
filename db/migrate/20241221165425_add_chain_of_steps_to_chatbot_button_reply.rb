class AddChainOfStepsToChatbotButtonReply < ActiveRecord::Migration[7.1]
  def change
    add_column :chatbot_button_replies, :chain_of_steps, :string
  end
end
