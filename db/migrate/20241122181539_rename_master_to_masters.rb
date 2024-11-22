class RenameMasterToMasters < ActiveRecord::Migration[7.1]
  def change
     rename_table :master, :masters
  end
end
