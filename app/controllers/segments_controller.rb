class SegmentsController < ApplicationController
  before_action :authorize_super_admin, only: [:destroy]

  def index
    @master_segment = MasterSegment.find(params[:master_segment_id])
    @segments = @master_segment.segments.where(segments: {is_deleted: false}).page(params[:page]).per(10)
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
