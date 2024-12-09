class MasterSegmentExcelImportJob < ApplicationJob
  queue_as :default

  def perform(file_url, master_segment_id, added_by_id)
    MasterSegmentExcelImportService.new(file_url, master_segment_id, added_by_id).import
  end
end
