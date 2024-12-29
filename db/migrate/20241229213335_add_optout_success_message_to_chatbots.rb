class AddOptoutSuccessMessageToChatbots < ActiveRecord::Migration[7.1]
  def change
    add_column :chatbots, :optout_success_message, :string
  end
end
