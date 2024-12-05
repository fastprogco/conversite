class UpdateTableTypeId < ActiveRecord::Migration[7.1]
  def change
    remove_column :segments, :table_type_id, :integer

    change_table :master_segments do |t|
      t.integer :table_type_id
    end
  end
end
