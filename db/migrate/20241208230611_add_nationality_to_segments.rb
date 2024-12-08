class AddNationalityToSegments < ActiveRecord::Migration[7.1]
  def change
    add_column :segments, :nationality, :string
  end
end
