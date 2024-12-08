class RemoveMasterSegmentIdFromChatbots < ActiveRecord::Migration[7.1]
  def change
    remove_column :chatbots, :master_segment_id, :integer
  end
end
