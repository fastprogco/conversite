class CreateChatbotLocationReplies < ActiveRecord::Migration[7.1]
  def change
    create_table :chatbot_location_replies do |t|
      t.string :location_name
      t.string :location_address
      t.decimal :location_latitude, precision: 10, scale: 6
      t.decimal :location_longitude, precision: 10, scale: 6
      t.references :chatbot, foreign_key: true
      t.references :chatbot_step, foreign_key: true
      t.integer :order
      t.references :added_by, foreign_key: { to_table: :users }, null: true
      t.datetime :added_on
      t.references :edited_by, foreign_key: { to_table: :users }, null: true
      t.datetime :edited_on
      t.references :deleted_by, foreign_key: { to_table: :users }, null: true
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
