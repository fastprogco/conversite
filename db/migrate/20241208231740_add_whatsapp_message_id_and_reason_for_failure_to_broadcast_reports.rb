class AddWhatsappMessageIdAndReasonForFailureToBroadcastReports < ActiveRecord::Migration[7.1]
  def change
    add_column :broadcast_reports, :whatsapp_message_id, :string
    add_column :broadcast_reports, :reason_for_failure, :string
  end
end
