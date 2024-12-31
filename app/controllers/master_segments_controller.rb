class MasterSegmentsController < ApplicationController
  before_action :authorize_super_admin, only: [:index, :destroy]

  def index
    @page = params[:page] || 1
    allowed_sort_columns = ['name', 'description', 'chain_of_steps', 'created_at']
    allowed_sort_descriptions = ['asc', 'desc']

    @sort_column = params[:sort].presence_in(allowed_sort_columns) || 'created_at'
    @sort_direction = params[:direction].presence_in(allowed_sort_descriptions) || 'desc'


    @master_segments = MasterSegment.where(is_deleted: false)

    if params[:name].present? || params[:mobile].present?
      @master_segments = @master_segments.joins(:segments)
                                          .where("segments.person_name ILIKE :name AND segments.mobile = :mobile", 
                                                name: "%#{params[:name]}%", mobile: params[:mobile])
                                          .distinct
                                         
    end

    @master_segments = @master_segments.order(Arel.sql("#{@sort_column} #{@sort_direction}")).page(@page).per(10)
  end



  def destroy
    @master_segment = MasterSegment.find(params[:id])
    chatbot_with_current_master_segment_exists = Chatbot.joins(:chatbots_master_segments).where(chatbots_master_segments: { master_segment_id: @master_segment.id }).where(chatbots: { is_deleted: false }).exists?
    if chatbot_with_current_master_segment_exists
      redirect_to master_segments_path, alert: 'Cannot delete master segment because it is being used by a chatbot. please delete the chatbot first.'
      return
    end
    @master_segment.is_deleted = true
    if @master_segment.save
      redirect_to master_segments_path, notice: 'Master segment was successfully deleted.'
    else
      redirect_to master_segments_path, alert: @master_segment.errors.full_messages.join(', ')
    end
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
