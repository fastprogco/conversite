class BroadcastsController < ApplicationController
  before_action :set_broadcast, only: [:edit, :update, :destroy]
  before_action :set_whatsapp_accounts, only: [:new, :edit, :create, :update]
  before_action :set_templates, only: [:new, :edit, :create, :update]
  before_action :set_master_segments, only: [:new, :edit, :create, :update]

  def index
    @page = params[:page] || 1
    @broadcasts = Broadcast.includes(:whatsapp_account, :template, :master_segment).where(is_deleted: false).order(created_at: :desc).page(@page).per(10)
  end

  def new
    @broadcast = Broadcast.new
  end

  def create
    @broadcast = Broadcast.new(broadcast_params.except(:timing))
    @broadcast.timing = broadcast_params[:timing].to_i
    @broadcast.added_by = current_user
    if @broadcast.save
      BroadcastJob.perform_later(@broadcast)
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
    params.require(:broadcast).permit(:name, :whatsapp_account_id, :template_id, :master_segment_id, :timing)
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
end
