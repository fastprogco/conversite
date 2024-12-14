class UpdateConversationsTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :conversations, :details, :text
    add_column :conversations, :image_url, :string
    add_column :conversations, :document_url, :string
    add_column :conversations, :file_caption, :string
    add_column :conversations, :latitude, :decimal, precision: 10, scale: 6
    add_column :conversations, :longitude, :decimal, precision: 10, scale: 6
    add_column :conversations, :location_name, :string
    add_column :conversations, :location_description, :string
    add_column :conversations, :text, :text
  end
end
