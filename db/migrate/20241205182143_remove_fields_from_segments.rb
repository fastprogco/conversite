class RemoveFieldsFromSegments < ActiveRecord::Migration[7.1]
  def change
    change_table :segments do |t|
      t.remove :name, :description
      t.references :master_segment, foreign_key: true, null: false
    end
  end
end
