class BroadcastReportsController < ApplicationController
  before_action :authorize_super_admin, only: [:index]

  def index
    @page = params[:page] || 1
    @broadcast = Broadcast.find(params[:broadcast_id])
    @message_status = params[:message_status] || ''
    @response_status = params[:response_status] || ''
    @status_counts = @broadcast.broadcast_reports
                              .where(message_status: BroadcastReport.message_statuses.values_at(:sent, :delivered, :read, :replied, :failed))
                              .group(:message_status)
                              .count

    puts "response Status is here #{@response_status}"
    # @broadcast_reports = @broadcast.broadcast_reports.order(created_at: :desc).page(@page).per(10).map do |report|
    #   last_conversation = Conversation.where(mobile_number: report.mobile_number).order(created_at: :desc).first
    #   report.attributes.merge(
    #     conversation_within_24_hours: last_conversation.present? && last_conversation.created_at > report.created_at + 24.hours ? 'No' : 'Yes'
    #   )
    # end

    @broadcast_reports = @broadcast.broadcast_reports
                              .joins("LEFT JOIN LATERAL (SELECT * FROM conversations WHERE conversations.mobile_number = broadcast_reports.mobile ORDER BY created_at DESC LIMIT 1) last_conversation ON true")
                              .select("broadcast_reports.*, 
                                        CASE 
                                          WHEN last_conversation.created_at IS NULL THEN 'No'
                                          WHEN last_conversation.created_at > broadcast_reports.created_at + interval '24 hours' THEN 'No'
                                          ELSE 'Yes'
                                        END AS conversation_within_last_24_hours_of_report")
                              .where("message_status = :message_status OR :message_status_string = '' OR :message_status_string = 'all'", message_status: BroadcastReport.message_statuses[@message_status], message_status_string: @message_status)
                              .where("(:response_status = 'yes' AND last_conversation.created_at IS NOT NULL AND last_conversation.created_at <= broadcast_reports.created_at + interval '24 hours') OR (:response_status = 'no' AND (last_conversation.created_at IS NULL OR last_conversation.created_at > broadcast_reports.created_at + interval '24 hours')) OR :response_status = ''", response_status: @response_status)
                              .order("broadcast_reports.created_at DESC")
                              .page(@page)
                              .per(10)
  end
end
