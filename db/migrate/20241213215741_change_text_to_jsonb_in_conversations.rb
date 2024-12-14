class ChangeTextToJsonbInConversations < ActiveRecord::Migration[7.1]
  def change
    change_column :conversations, :text, :jsonb, using: 'text::jsonb'
  end
end
