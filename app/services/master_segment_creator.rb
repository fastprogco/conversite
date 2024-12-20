class MasterSegmentCreator
  def initialize(master_segment_id, master_ids, user_id)
    @master_segment_id = master_segment_id
    @master_ids = master_ids
    @user_id = user_id
  end

  def call
    Rails.logger.info "Starting segment creation for master_segment_id: #{@master_segment_id}"
    Rails.logger.info "Processing #{@master_ids.size} master records"

    ActiveRecord::Base.transaction do
      @master_ids.each_with_index do |master_id, index|
        Rails.logger.info "Processing master record #{index + 1}/#{@master_ids.size} (ID: #{master_id})"
        
        master = Master.find(master_id)
        Segment.create!(
          master_segment_id: @master_segment_id, 
          mobile: master.mobile,
          person_name: master.name,
          person_email: master.email,
          added_by_id: @user_id,
          added_on: DateTime.now.utc,
          nationality: master.nationality
        )
        Rails.logger.info "Successfully created segment for master_id: #{master_id}"
      end
    end

    Rails.logger.info "Completed segment creation for master_segment_id: #{@master_segment_id}"
  end
end