class CreateEmailSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :email_settings do |t|
      t.string :name
      t.string :smtp_host
      t.integer :port
      t.string :email_address
      t.string :user_name
      t.string :password

      t.timestamps
    end
  end
end
