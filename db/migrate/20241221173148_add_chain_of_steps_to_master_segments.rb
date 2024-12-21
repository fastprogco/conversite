class AddChainOfStepsToMasterSegments < ActiveRecord::Migration[7.1]
  def change
    add_column :master_segments, :chain_of_steps, :string
  end
end
