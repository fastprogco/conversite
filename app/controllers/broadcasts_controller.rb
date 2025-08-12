class BroadcastsController < ApplicationController
  before_action :set_broadcast, only: [:edit, :update, :destroy]
  before_action :set_whatsapp_accounts, only: [:new, :edit, :create, :update]
  before_action :set_templates, only: [:new, :edit, :create, :update]
  before_action :set_master_segments, only: [:new, :edit, :create, :update]

  before_action :authorize_super_admin, only: [:index, :new, :create, :edit, :update, :destroy, :send_now]

  def index
    @page = params[:page] || 1
    @broadcasts = Broadcast.includes(:whatsapp_account, :template, :master_segment).where(is_deleted: false).order(created_at: :desc).page(@page).per(10)
  end

  def new
    @broadcast = Broadcast.new
  end

  def create
    @broadcast = Broadcast.new(broadcast_params.except(:timing, :file))
    @broadcast.timing = broadcast_params[:timing].to_i
    @broadcast.added_by = current_user
    if @broadcast.save

      should_return =  upload_file_and_check_should_return(broadcast_params[:file])
      return if should_return
      redirect_to broadcasts_path, notice: 'Broadcast was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @broadcast.edited_by = current_user
    if @broadcast.update(broadcast_params.except(:timing))
      @broadcast.timing = broadcast_params[:timing].to_i
      @broadcast.save
      redirect_to broadcasts_path, notice: 'Broadcast was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @broadcast.deleted_by = current_user
    @broadcast.is_deleted = true
    if @broadcast.save
      redirect_to broadcasts_path, notice: 'Broadcast was successfully deleted.'
    else
      redirect_to broadcasts_path, alert: 'Failed to delete broadcast.'
    end
  end

  def send_now
    @broadcast = Broadcast.find(params[:id])
    BroadcastJob.perform_later(@broadcast)
    redirect_to broadcasts_path, notice: 'Broadcast was successfully started.'
  end

  private

  def set_broadcast
    @broadcast = Broadcast.find(params[:id])
  end

  def broadcast_params
    params.require(:broadcast).permit(:name, :whatsapp_account_id, :template_id, :master_segment_id, :timing, :scheduled_at, :file)
  end

  def set_whatsapp_accounts
    @whatsapp_accounts = WhatsappAccount.where(is_deleted: false)
  end

  def set_templates
    @templates = Template.where(is_deleted: false)
  end

  def set_master_segments
    @master_segments = MasterSegment.where(is_deleted: false)
  end

  def upload_file_and_check_should_return(file)
        return unless file.present?
        redirect_to new_broadcast_path, alert: t("please_select_a_file") if file.nil?
        return true if file.blank?

       # Upload file to S3 using S3FileUploader service
       environment = Rails.env.production? ? "prod" : "dev"
       begin
        puts "Uploading file to S3: #{file.tempfile.path}"
        @file_url = S3FileUploader.upload(file.tempfile.path, environment)
       rescue StandardError => e
          redirect_to new_broadcast_path, alert: t("upload_to_s3_error") + ": #{e.message}"
          return true
       end

      service = BroadcastExcelImportService.new(@file_url)
      mobile_numbers = service.import
      if @broadcast.timing.to_sym == :schedule  
        BroadcastJob.set(wait_until: @broadcast.scheduled_at - SITE_TIME_OFFSET.hours).perform_later(@broadcast, mobile_numbers)
      else
        BroadcastJob.perform_later(@broadcast, mobile_numbers)
      end
       return false
  end
end
