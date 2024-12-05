class WebhookController < ApplicationController
  include Chatbot::Flow
  
  skip_before_action :verify_authenticity_token
  def receive
    message_status = params.dig("entry", 0, "changes", 0, "value", "statuses", 0,  "status")
    to_phone_number = params.dig('entry', 0, 'changes', 0, 'value', 'contacts', 0, 'wa_id')

    puts "new whatsapp message status #{message_status}" 
    puts "whatsapp payload headers: #{request.headers.to_h}"

    #only go for chatbot flow if the message status is nil
    #because if there is a status it means it is read, delivered or failed message and we are only interested in the new message
    if message_status.nil?
       #timestamp = params.dig("entry", 0, "changes", 0, "value", "messages", 0, "timestamp")
       start(to_phone_number, params)
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

    if mode == 'subscribe' && token == "globex-123-secure-token"
      render plain: challenge
      Rails.logger.info "Webhook verified successfully!"
    else
      head :forbidden
    end
  end

end
