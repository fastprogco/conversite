class MasterSegmentsController < ApplicationController
  before_action :authorize_super_admin, only: [:index, :destroy]

  def index
    @page = params[:page] || 1
    @master_segments = MasterSegment.where(is_deleted: false).page(@page).per(10)
  end

  def destroy
    @master_segment = MasterSegment.find(params[:id])
    @master_segment.is_deleted = true
    @master_segment.save
    redirect_to master_segments_path, notice: 'Master segment was successfully deleted.'
  end
end
