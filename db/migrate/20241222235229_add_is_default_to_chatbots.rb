class AddIsDefaultToChatbots < ActiveRecord::Migration[7.1]
  def change
    add_column :chatbots, :is_default, :boolean, default: false
  end
end
