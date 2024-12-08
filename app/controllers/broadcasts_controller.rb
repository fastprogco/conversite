class BroadcastsController < ApplicationController
  before_action :set_broadcast, only: [:edit, :update, :destroy]

  def index
    @page = params[:page] || 1
    @broadcasts = Broadcast.where(is_deleted: false).page(@page).per(10)
  end

  def new
    @broadcast = Broadcast.new
    @whatsapp_accounts = WhatsappAccount.where(is_deleted: false)
    @templates = Template.where(is_deleted: false)
    @master_segments = MasterSegment.where(is_deleted: false)
  end

  def create
    @broadcast = Broadcast.new(broadcast_params)
    @broadcast.added_by = current_user
    if @broadcast.save
      redirect_to broadcasts_path, notice: 'Broadcast was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @whatsapp_accounts = WhatsappAccount.where(is_deleted: false)
    @templates = Template.where(is_deleted: false)
    @master_segments = MasterSegment.where(is_deleted: false)
  end

  def update
    @broadcast.edited_by = current_user
    if @broadcast.update(broadcast_params)
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

  private

  def set_broadcast
    @broadcast = Broadcast.find(params[:id])
  end

  def broadcast_params
    params.require(:broadcast).permit(:name, :whatsapp_account_id, :template_id, :master_segment_id, :timing)
  end
end
