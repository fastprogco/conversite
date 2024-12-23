class AddTriggerMasterSegmentNameToChatbotSteps < ActiveRecord::Migration[7.1]
  def change
    add_column :chatbot_steps, :trigger_master_segment_name, :string
  end
end
