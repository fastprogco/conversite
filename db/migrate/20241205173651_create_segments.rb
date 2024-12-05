class CreateSegments < ActiveRecord::Migration[7.1]
  def change
    create_table :segments do |t|
      t.integer :table_type_id, null: false
      t.integer :table_id, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.timestamps
    end
  end
end
