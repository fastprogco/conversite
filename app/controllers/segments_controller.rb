class SegmentsController < ApplicationController
  def index
    @master_segment = MasterSegment.find(params[:master_segment_id])
    case @master_segment.table_type_id.to_sym
    when :master
      @segments = @master_segment.segments.where(segments: {is_deleted: false}).page(params[:page]).per(10)
    end
  end

  def destroy
    @master_segment = MasterSegment.find(params[:master_segment_id])
    @segment = Segment.find(params[:id])
    @segment.is_deleted = true
    @segment.deleted_by = current_user
    if @segment.save
      redirect_to master_segment_segments_path(@master_segment), notice: 'Segment was successfully deleted.'
    else
      redirect_to master_segment_segments_path(@master_segment), alert: 'Failed to delete segment.'
    end
  end
end
