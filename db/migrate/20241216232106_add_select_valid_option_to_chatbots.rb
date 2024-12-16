class AddSelectValidOptionToChatbots < ActiveRecord::Migration[7.1]
  def change
    add_column :chatbots, :select_valid_option, :text
  end
end
