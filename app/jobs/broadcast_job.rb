class BroadcastJob < ApplicationJob
  queue_as :default

  def perform(broadcast, mobile_numbers)
    whatsapp_account = broadcast.whatsapp_account
    template = broadcast.template
    timing = broadcast.timing.to_sym

    puts "Starting Broadcast Job"
    #broadcast.master_segment.segments.where(is_deleted: false).select('DISTINCT ON (mobile) *').each do |segment|
    mobile_numbers.each do |mobile|
      puts "Sending message to #{mobile}"

      if !mobile.present?
        next
      end

      response = WhatsappMessageService.send_text_message_template_with_phone_number_id(
        mobile,
        template.meta_template_name,
        template.language,
        template.component.present? ? JSON.parse(template.component) : {},
        whatsapp_account.phone_number_id,
        whatsapp_account.token
      )
      puts "Response FROM WHATSAPP: #{response}"

      if response.is_a?(Hash) && response[:error].present?
        puts "Error: #{response[:error]}"
        if response[:body].present?
          error_body = JSON.parse(response[:body]) rescue nil
          if error_body && error_body['error']
            BroadcastReport.create(
              broadcast: broadcast,
              broadcast_name: broadcast.name,
              mobile: mobile,
              name: "",
              nationality: "",
              message_status: :failed,
              reason_for_failure: error_body['error']['message']
            )
          end
        end
      else
        BroadcastReport.create(
          broadcast: broadcast,
          broadcast_name: broadcast.name,
          mobile: mobile,
          name: "",
          nationality: "",
          message_status: :sent,
          sent_on: Time.now.utc,
          whatsapp_message_id: response.is_a?(HTTP::Response) ? JSON.parse(response.body)['messages'].first['id'] : response['messages'].first['id']
        )
      end
    end
  end
end
