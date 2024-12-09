class BroadcastJob < ApplicationJob
  queue_as :default

  def perform(broadcast)
    whatsapp_account = broadcast.whatsapp_account
    template = broadcast.template
    timing = broadcast.timing.to_sym

    puts "Starting Broadcast Job"
    broadcast.master_segment.segments.select('DISTINCT ON (mobile) *').each do |segment|
      puts "Sending message to #{segment.mobile}"
      response = WhatsappMessageService.send_text_message_template_with_phone_number_id(
        segment.mobile,
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
            puts "Error Message: #{error_body['error']['message']}"
            puts "Error Type: #{error_body['error']['type']}" 
            puts "Error Code: #{error_body['error']['code']}"
            puts "FB Trace ID: #{error_body['error']['fbtrace_id']}"
            puts "whatsapp_message_id: #{error_body['error']['whatsapp_message_id']}"

            BroadcastReport.create(
              broadcast: broadcast,
              broadcast_name: broadcast.name,
              mobile: segment.mobile,
              name: segment.person_name,
              nationality: segment.nationality,
              message_status: :failed,
              reason_for_failure: error_body['error']['message']
            )
          end
        end
      else
        BroadcastReport.create(
          broadcast: broadcast,
          broadcast_name: broadcast.name,
          mobile: segment.mobile,
          name: segment.person_name,
          nationality: segment.nationality,
          message_status: :sent,
          sent_on: Time.now.utc,
          whatsapp_message_id: response.is_a?(HTTP::Response) ? JSON.parse(response.body)['messages'].first['id'] : response['messages'].first['id']
        )
      end
    end
  end
end
