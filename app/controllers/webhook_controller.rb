class WebhookController < ApplicationController
  include ChatbotCode::Flow
  
  skip_before_action :verify_authenticity_token
  def receive
    message_status = params.dig("entry", 0, "changes", 0, "value", "statuses", 0,  "status")
    timestamp = params.dig("entry", 0, "changes", 0, "value", "statuses", 0, "timestamp")
    whatsapp_message_id = params.dig("entry", 0, "changes", 0, "value", "statuses", 0, "id")
    to_phone_number = params.dig('entry', 0, 'changes', 0, 'value', 'contacts', 0, 'wa_id')

    puts "new whatsapp message status #{message_status}" 
    #puts "whatsapp payload headers: #{request.headers.to_h}"



    #only go for chatbot flow if the message status is nil
    #because if there is a status it means it is read, delivered or failed message and we are only interested in the new message
    if message_status.nil?
       start(to_phone_number, params)
    else
      check_broadcast_reports(to_phone_number, params)
    end

    head :ok
  end

  def verify
    mode = params['hub.mode']
    token = params['hub.verify_token']
    challenge = params['hub.challenge']

    puts mode
    puts token
    puts challenge

    if mode == 'subscribe' && token == "conversite-123-secure-token"
      render plain: challenge
      Rails.logger.info "Webhook verified successfully!"
    else
      head :forbidden
    end
  end

end
