class CreateMasterSegmentsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :master_segments do |t|
        t.string :name
        t.text :description
        t.references :added_by, foreign_key: { to_table: :users }, null: true
        t.datetime :added_on
        t.references :edited_by, foreign_key: { to_table: :users }, null: true
        t.datetime :edited_on
        t.boolean :is_deleted, default: false
        t.references :deleted_by, foreign_key: { to_table: :users }, null: true

        t.timestamps
      end
  end
end
