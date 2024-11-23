class AddNameAndLandSubNumToMasters < ActiveRecord::Migration[7.1]
  def change
    add_column :masters, :name, :string
    add_column :masters, :land_sub_num, :string
  end
end
