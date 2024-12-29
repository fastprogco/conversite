class CreateOptouts < ActiveRecord::Migration[7.1]
  def change
    create_table :optouts do |t|
      t.string :mobile_number
      t.string :facebook_name

      t.timestamps
    end
  end
end
