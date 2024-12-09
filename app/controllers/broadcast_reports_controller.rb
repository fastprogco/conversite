class BroadcastReportsController < ApplicationController
  before_action :authorize_super_admin, only: [:index]

  def index
    @page = params[:page] || 1
    @broadcast = Broadcast.find(params[:broadcast_id])
    @broadcast_reports = @broadcast.broadcast_reports.order(created_at: :desc).page(@page).per(10)
  end
end
