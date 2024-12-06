module ChatbotCode
  module Flow
    extend ActiveSupport::Concern

    def start(to_phone_number, params)
      puts "starting flow"

      decide_next_step(to_phone_number, params)
    end

    def decide_next_step(to_phone_number, recieved_params)
      payload = get_message_back_payload(recieved_params)
      button_reply_id = payload&.dig(:button_reply_id)
      list_reply_id = payload&.dig(:list_reply_id) 
      message_response_body = payload&.dig(:message_response_body)
      
      reply_id = list_reply_id || button_reply_id

      puts "reply_id: #{reply_id}"

      if reply_id.present?
        is_back_button = reply_id.include?("BACK_")
        if is_back_button
          chatbot_step = ChatbotStep.find(reply_id.split("_").last)
        else
          chatbot_step = ChatbotStep.find_by(chatbot_button_reply_id: reply_id)
        end
      else
        chatbot_step = find_chatbot_step(to_phone_number)
      end

      send_message(to_phone_number, chatbot_step)
      send_mutlimedia_messages(to_phone_number, chatbot_step)
      send_location_messages(to_phone_number, chatbot_step)
    end


    def find_chatbot_step(to_phone_number)
        result = Segment.joins("JOIN master_segments ON segments.master_segment_id = master_segments.id")
          .joins("JOIN chatbots ON chatbots.master_segment_id = master_segments.id")
          .joins("LEFT JOIN masters ON masters.id = segments.table_id")
          .order("chatbots.created_at DESC")
          .where("masters.mobile = ?", to_phone_number)
          .select("chatbots.id AS chatbot_id, chatbots.created_at AS chatbot_created_at")
          .first


      chatbot = result.chatbot_id ? Chatbot.find(result.chatbot_id) : Chatbot.find_by(master_segment_id: nil)
      chatbot_step = chatbot.chatbot_steps.where(chatbot_button_reply_id: nil).first
      return chatbot_step
    end


    def send_message(to_phone_number, chatbot_step)

      if chatbot_step.nil?
        return
      end

      buttons_count = chatbot_step.chatbot_button_replies.count

      if buttons_count > 2
        send_message_as_interactive_list(to_phone_number, chatbot_step)
        return;
      end

      buttons = chatbot_step.chatbot_button_replies.map { |button| { type: "reply", reply: { id: button.id, title: button.title } } }
      buttons.push({ type: "reply", reply: { id: "BACK_#{chatbot_step.previous_chatbot_step_id}", title: "back" } }) if chatbot_step.previous_chatbot_step_id.present?
      header = chatbot_step.header
      body = chatbot_step.description
      footer = chatbot_step.footer

      interactive_payload =  {
          type: 'button',
          header: {
            type: "text",
            text: header
          },
          body: {
            text: body
          },
          footer: {
            text: footer
          },
          action: {
            buttons: buttons
          }
        }
      response = WhatsappMessageService.send_interactive_message(to_phone_number, interactive_payload  )
    end

    def send_message_as_interactive_list(to_phone_number, chatbot_step)
      
        rows = chatbot_step.chatbot_button_replies.map do |button|
          {
            id: button.id,
            title: button.title,
          }
        end

        if chatbot_step.previous_chatbot_step_id.present? && chatbot_step.chatbot_button_reply_id.present?
          rows.push({
            id: "BACK_#{chatbot_step.previous_chatbot_step_id}",
            title: "back"
          })
        end

        interactive_list_message_object = {
          type: "list", 
          body: {
            text: chatbot_step.description
          },
          action: {
            button: chatbot_step.list_button_caption,
            sections: [
              {
                title: chatbot_step.header,
                rows: rows
              }
            ]
          }
        }
        WhatsappMessageService.send_interactive_list_message(to_phone_number, interactive_list_message_object)
    end

    def get_message_back_payload(recieved_params)
      button_reply_id = recieved_params.dig('entry', 0, 'changes', 0, 'value', 'messages', 0, 'interactive', 'button_reply', "id")
      
      message_response_body = recieved_params.dig('entry', 0, 'changes', 0, 'value', 'messages', 0, 'text', 'body')

      list_reply_id = recieved_params.dig("entry", 0, "changes", 0, "value", "messages", 0, "interactive", "list_reply", "id")
     
      { button_reply_id: button_reply_id, message_response_body: message_response_body, list_reply_id: list_reply_id }
    end

    def send_mutlimedia_messages(to_phone_number, chatbot_step)
      mutlimedia_replies = chatbot_step.chatbot_multimedia_replies.order(:order)
      mutlimedia_replies.each do |mutlimedia_reply|
        case mutlimedia_reply.media_type_id.to_sym
        when :image
          send_image_message(to_phone_number, url_for(mutlimedia_reply.file), mutlimedia_reply.file_caption)
        when :video, :document, :audio
          send_document_message(to_phone_number, url_for(mutlimedia_reply.file), mutlimedia_reply.file_caption)
        when :text
          send_text_message(to_phone_number, mutlimedia_reply.text_body)
        end
      end
    end

    def send_location_messages(to_phone_number, chatbot_step)
      location_replies = chatbot_step.chatbot_location_replies.order(:order)
      location_replies.each do |location_reply|
        send_location_message(to_phone_number, location_reply.location_latitude, location_reply.location_longitude, location_reply.location_name, location_reply.location_address)
      end
    end

    def send_image_message(to_phone_number, image_url, file_caption)
      WhatsappMessageService.send_image_message(to_phone_number, image_url, file_caption) if image_url.present?
    end

    def send_document_message(to_phone_number, document_url, file_caption)
      WhatsappMessageService.send_document_link(to_phone_number, document_url, file_caption) if document_url.present?
    end

    def send_location_message(to_phone_number, latitude, longitude, location_name, location_description)
      WhatsappMessageService.send_location_message(to_phone_number, latitude, longitude, location_name, location_description) if latitude.present? && longitude.present?
    end

    def send_text_message(to_phone_number, text)
      WhatsappMessageService.send_text_message(to_phone_number, text) if text.present?
    end

  end
end
