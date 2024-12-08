class MasterSegmentCreator
  def initialize(master_segment_id, master_ids, user_id)
    @master_segment_id = master_segment_id
    @master_ids = master_ids
    @user_id = user_id
  end

  def call
    ActiveRecord::Base.transaction do
      @master_ids.each do |master_id|
        master = Master.find(master_id)
        Segment.create!(master_segment_id: @master_segment_id, mobile: master.mobile, person_name: master.name, person_email: master.email, added_by_id: @user_id, added_on: DateTime.now.utc)
      end
    end
  end
end