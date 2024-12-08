class CreateJoinTableChatbotsMasterSegments < ActiveRecord::Migration[7.1]
  def change
    create_join_table :chatbots, :master_segments do |t|
      t.index :chatbot_id
      t.index :master_segment_id
    end
  end
end
