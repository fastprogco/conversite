class MasterSegmentsController < ApplicationController
  before_action :authorize_super_admin, only: [:index, :destroy]

  def index
    @page = params[:page] || 1
    @master_segments = MasterSegment.where(is_deleted: false).order(created_at: :desc).page(@page).per(10)
  end

  def destroy
    @master_segment = MasterSegment.find(params[:id])
    @master_segment.is_deleted = true
    @master_segment.save
    redirect_to master_segments_path, notice: 'Master segment was successfully deleted.'
  end

  def new
    @master_segment = MasterSegment.new
  end

  def create
    @master_segment = MasterSegment.new(master_segment_params.except(:excel_file))
    @master_segment.added_by_id = current_user.id
    
    return redirect_to new_master_segment_path, alert: t("please_select_a_file") if master_segment_params[:excel_file].nil?

    if @master_segment.save
      uploaded_file = master_segment_params[:excel_file]

      # Upload file to S3 using S3FileUploader service
      begin
        @file_url = S3FileUploader.upload(uploaded_file.tempfile.path, "dev")
      rescue StandardError => e
        return redirect_to new_master_segment_path, alert: t("upload_to_s3_error") + ": #{e.message}"
      end

      MasterSegmentExcelImportJob.perform_later(@file_url, @master_segment.id, current_user.id)
      redirect_to master_segments_path, notice: t("data_import_is_in_progress")
    else
      render :new, status: :unprocessable_entity
    end
  rescue StandardError => e
    redirect_to new_master_segment_path, alert: t("error") + ": #{e.message}"
  end

  private 
  def master_segment_params
    params.require(:master_segment).permit(:name, :description, :excel_file)
  end
end
