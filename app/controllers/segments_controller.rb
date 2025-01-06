class SegmentsController < ApplicationController
  before_action :authorize_super_admin, only: [:index, :new, :create, :edit, :update, :destroy, :show, :segments_by_id]
  before_action :set_master_segment, only: [:index, :new, :create, :edit, :update, :destroy, :show]

  def index
    @segments = @master_segment.segments.where(segments: {is_deleted: false}).page(params[:page]).per(10)
  end

  def destroy
    @segment = Segment.find(params[:id])
    @segment.is_deleted = true
    @segment.deleted_by = current_user
    if @segment.save
      redirect_to master_segment_segments_path(@master_segment), notice: 'Segment was successfully deleted.'
    else
      redirect_to master_segment_segments_path(@master_segment), alert: 'Failed to delete segment.'
    end
  end

  def new
    @segment = @master_segment.segments.new
  end

  def create
    @segment = @master_segment.segments.new(segment_params)
    @segment.added_by = current_user
    if @segment.save
      redirect_to master_segment_segments_path(@master_segment), notice: 'Segment was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @segment = @master_segment.segments.find(params[:id])
  end

  def update
    @segment = @master_segment.segments.find(params[:id])
    if @segment.update(segment_params)
      redirect_to master_segment_segments_path(@master_segment), notice: 'Segment was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @segment = @master_segment.segments.find(params[:id])
  end

  def segments_by_id
    segment_ids = params[:segment_ids]
    @segments = Segment.where(id: segment_ids).page(params[:page]).per(10)
  end


  private

  def segment_params
    params.require(:segment).permit(:person_name, :mobile, :person_email, :nationality)
  end

  def set_master_segment
    @master_segment = MasterSegment.find(params[:master_segment_id])
  end
end
