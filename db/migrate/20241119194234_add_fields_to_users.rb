class AddFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :role, default: "user"
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :email_confirmation_token
      t.string :phone
      t.datetime :email_confirmed_at
      t.datetime :email_confirmation_sent_at
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.string :phone_confirmation_token
      t.datetime :phone_confirmed_at
      t.datetime :phone_confirmation_sent_at
      t.boolean :is_deleted, default: false

      t.timestamps
    end

    add_index :users, :email
    add_index :users, :reset_password_token
    add_index :users, :phone_confirmation_token
    add_index :users, :phone
    add_index :users, :is_deleted
  end
end
