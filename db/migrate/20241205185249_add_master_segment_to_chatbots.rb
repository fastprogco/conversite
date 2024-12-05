class AddMasterSegmentToChatbots < ActiveRecord::Migration[7.1]
  def change
    add_reference :chatbots, :master_segment, null: true, foreign_key: true
  end
end
