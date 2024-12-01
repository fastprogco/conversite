class CreateChatbotSteps < ActiveRecord::Migration[7.1]
  def change
    create_table :chatbot_steps do |t|
      t.references :chatbot, foreign_key: true
      t.references :previous_chatbot_step, foreign_key: { to_table: :chatbot_steps }, null: true
      t.string :header
      t.text :description
      t.string :footer
      t.string :list_button_caption
      t.boolean :is_deleted, default: false
      t.references :deleted_by, foreign_key: { to_table: :users }, null: true
      t.references :created_by, foreign_key: { to_table: :users }, null: true
      t.references :edited_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end
  end
end
