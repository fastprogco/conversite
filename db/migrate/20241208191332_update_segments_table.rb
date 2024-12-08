class UpdateSegmentsTable < ActiveRecord::Migration[7.1]
  def change
    change_table :segments do |t|
      t.string :mobile
      t.string :person_name
      t.string :person_email
      t.change :table_id, :integer, null: true
    end
  end
end
