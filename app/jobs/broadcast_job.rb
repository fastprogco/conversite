class BroadcastJob < ApplicationJob
  queue_as :default

  def perform(broadcast)
    whatsapp_account = broadcast.whatsapp_account
    template = broadcast.template
    timing = broadcast.timing.to_sym

    puts "Starting Broadcast Job"
    if timing == :send_now
      broadcast.master_segment.segments.each do |segment|
        puts "Sending message to #{segment.mobile}"
        response = WhatsappMessageService.send_text_message_template(
          segment.mobile,
          template.meta_template_name,
          template.language,
          template.component.present? ? JSON.parse(template.component) : {}
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
            end
          end
        else
          puts "Message sent successfully"
        end
      end
    else
      BroadcastJob.set(wait_until: broadcast.scheduled_at).perform_later(broadcast)
    end
  end
end
