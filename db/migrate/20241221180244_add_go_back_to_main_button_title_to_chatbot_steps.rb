class AddGoBackToMainButtonTitleToChatbotSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :chatbot_steps, :go_back_to_main_button_title, :string
  end
end
