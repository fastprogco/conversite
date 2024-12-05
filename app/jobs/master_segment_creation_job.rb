class MasterSegmentCreationJob < ApplicationJob
  queue_as :default

  def perform(master_segment_id, master_ids, user_id)
    MasterSegmentCreator.new(master_segment_id, master_ids, user_id).call
  end
end