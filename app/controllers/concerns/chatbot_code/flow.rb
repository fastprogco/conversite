module ChatbotCode
  module Flow
    extend ActiveSupport::Concern



    def start(to_phone_number, params)
      puts "starting flow"
      decide_next_step(to_phone_number, params)
    end

    
    def check_broadcast_reports(to_phone_number, params)
      message_status = params.dig("entry", 0, "changes", 0, "value", "statuses", 0,  "status")
      timestamp = params.dig("entry", 0, "changes", 0, "value", "statuses", 0, "timestamp")
      whatsapp_message_id = params.dig("entry", 0, "changes", 0, "value", "statuses", 0, "id")
      error_details = {
        title: params.dig("entry", 0, "changes", 0, "value", "statuses", 0, "errors", 0, "title"),
        message: params.dig("entry", 0, "changes", 0, "value", "statuses", 0, "errors", 0, "message"),
        details: params.dig("entry", 0, "changes", 0, "value", "statuses", 0, "errors", 0, "error_data", "details")
      }

      puts "message status: #{message_status}"

      broadcast_report = BroadcastReport.where(whatsapp_message_id: whatsapp_message_id).first
      if broadcast_report.present?
        if message_status == "delivered"
          broadcast_report.update(message_status: message_status, delivered_on: Time.at(timestamp.to_i).utc)
        elsif message_status == "read"
          broadcast_report.update(message_status: message_status, seen_on: Time.at(timestamp.to_i).utc)
        elsif message_status == "failed"
          broadcast_report.update(message_status: message_status, reason_for_failure: error_details.to_s)
        end
      end
    end

    def decide_next_step(to_phone_number, recieved_params)
      payload = get_message_back_payload(recieved_params)
      button_reply_id = payload&.dig(:button_reply_id)
      list_reply_id = payload&.dig(:list_reply_id) 
      message_response_body = payload&.dig(:message_response_body)
      user_name = payload&.dig(:user_name)
      button_payload = payload&.dig(:button_payload)

      if message_response_body.present?
        create_conversation(to_phone_number, { text: { content: message_response_body } }, false)
      end

      reply_id = list_reply_id || button_reply_id

      puts "reply_id: #{reply_id}"

      #finds the latest chatbot the user is int
      lastest_user_chatbot_step = find_chatbot_step(to_phone_number)

      if reply_id.present?

        if return_if_send_all_message_to_switched_chatbot_user(to_phone_number, lastest_user_chatbot_step, reply_id)
          return
        end

        is_back_button = reply_id.include?("BACK_")
        if is_back_button
          chatbot_step = ChatbotStep.find(reply_id.split("_").last)
          create_conversation(to_phone_number, { text: { buttons: "back" } }, false) if reply_id.present?
          if lock_user_in_chatbot_step(to_phone_number, reply_id)
            return
          end
        else
          button_reply = ChatbotButtonReply.find(reply_id)
          create_conversation(to_phone_number, { text: { buttons: button_reply.title } }, false) if reply_id.present?

          save_segment_if_is_trigger(to_phone_number, button_reply, user_name)


          if (button_reply.present?)
            puts "button reply present"
            if (button_reply.action_type_id.to_sym == :forward)
              chatbot_step = ChatbotStep.find_by(chatbot_button_reply_id: reply_id)
            elsif (button_reply.action_type_id.to_sym == :go_back_to_main)
              chatbot_step = lastest_user_chatbot_step
            end
          end

          if lock_user_in_chatbot_step(to_phone_number, reply_id)
            return
          end
        end
        if chatbot_step.present?
          save_user_chatbot_interaction(to_phone_number, chatbot_step, reply_id)
        end
      else
        #if no button payload it means it si not a template button click
        # if it is a template button click then  send the latest chatbot step messages
        if !button_payload.present?
          if lock_user_in_chatbot_step(to_phone_number, nil, lastest_user_chatbot_step)
            return
          end
        else
          interaction = get_user_chatbot_interaction(to_phone_number)
          interaction.update(is_first_step_after_template_button_click: true)
        end
        chatbot_step = lastest_user_chatbot_step
      end

      send_all_messages(to_phone_number, chatbot_step)
    end

    def send_all_messages(to_phone_number, chatbot_step)
    if chatbot_step.present?
        send_message(to_phone_number, chatbot_step)
        send_mutlimedia_messages(to_phone_number, chatbot_step)
        send_location_messages(to_phone_number, chatbot_step)
      end
    end

    def save_user_chatbot_interaction(to_phone_number, chatbot_step, clicked_button_id)
      existing_interaction = get_user_chatbot_interaction(to_phone_number);
      if existing_interaction.present?
        existing_interaction.update(chatbot_step_id: chatbot_step.id, clicked_button_id: clicked_button_id, chatbot_id: chatbot_step.chatbot_id)
      else
        UserChatbotInteraction.create(mobile_number: to_phone_number, chatbot_step_id: chatbot_step.id, clicked_button_id: clicked_button_id, chatbot_id: chatbot_step.chatbot_id)
      end
    end

    def get_user_chatbot_interaction(to_phone_number)
      UserChatbotInteraction.find_by(mobile_number: to_phone_number)
    end

    def lock_user_in_chatbot_step(to_phone_number, incoming_clicked_button_id, latest_user_chatbot_step = nil)
      user_chatbot_interaction = get_user_chatbot_interaction(to_phone_number)

      if user_chatbot_interaction.present?

        #if there is no incoming click , meaning it is another type of message
        #check if the users saved chatbot step is in the same chatbot as the latest chatbot step
        #if it , then don't allow him to futther because he clicked on a different button than the allowed flow
        if latest_user_chatbot_step.present? && incoming_clicked_button_id == nil
          if(latest_user_chatbot_step.chatbot.id == user_chatbot_interaction.chatbot_id)
            send_please_select_valid_option_message(to_phone_number, latest_user_chatbot_step.chatbot.select_valid_option)
            return true
          else
            return false
          end
        end
        
        chatbot = Chatbot.find(user_chatbot_interaction.chatbot_id)

        puts "saved step id: #{user_chatbot_interaction.chatbot_step_id}"
        puts "incoming clicked button id: #{incoming_clicked_button_id}"
        is_incoming_clicked_button_back_button = incoming_clicked_button_id.include?("BACK_")
        is_saved_clicked_button_back_button = user_chatbot_interaction.clicked_button_id.include?("BACK_")

        #check if the saved interaction is go back to main 
        #if it is go back to main then check if the incoming clicked button is in the button reply ids of the current chatbot step
        #if it is not in the button reply ids block the flow
        if !is_saved_clicked_button_back_button
          is_current_save_interaction_go_back_to_main = ChatbotButtonReply.find(user_chatbot_interaction.clicked_button_id).action_type_id.to_sym == :go_back_to_main
          if is_current_save_interaction_go_back_to_main
            chatbot = Chatbot.find(user_chatbot_interaction.chatbot_id)
            chatbot_first_step  = chatbot.chatbot_steps.where(chatbot_button_reply_id: nil).first
            if chatbot_first_step.present?
              button_reply_ids = chatbot_first_step.chatbot_button_replies.pluck(:id)
              if(!button_reply_ids.include?(incoming_clicked_button_id.to_i))
                return true
              end
            end
          end
        end

        # if both are back buttons
        #you want to check if the incoming steps button_reply_ids includees saved chatbot_button_reply_id
        if(is_incoming_clicked_button_back_button && is_saved_clicked_button_back_button)
          puts "HERE WE ARE IN THE BOTH SBACK BUTTON"
          puts "ids #{ChatbotStep.find(incoming_clicked_button_id.split("_").last.to_i).chatbot_button_replies.pluck(:id)} "
          puts "incoming id #{incoming_clicked_button_id}"
          puts "chabot_button_reply_id #{ChatbotStep.find(incoming_clicked_button_id.split("_").last.to_i).chatbot_button_reply_id}"
          if(!ChatbotStep.find(incoming_clicked_button_id.split("_").last.to_i).chatbot_button_replies.pluck(:id).include?(ChatbotStep.find(user_chatbot_interaction.clicked_button_id.split("_").last.to_i).chatbot_button_reply_id))
            send_please_select_valid_option_message(to_phone_number, chatbot.select_valid_option)
            return true
          end
        end
        # if incoming is back button and saved is not back button
        #you want to check  if the previous step id of the saved step is equal to the incoming step id
        if(is_incoming_clicked_button_back_button && !is_saved_clicked_button_back_button)
          if(incoming_clicked_button_id.split("_").last.to_i != ChatbotStep.find(user_chatbot_interaction.chatbot_step_id).previous_chatbot_step_id)
            send_please_select_valid_option_message(to_phone_number, chatbot.select_valid_option)
            return true
          end
        end
        # if incoming is not back button and saved is back button
        #you want to check if the saved step button reply ids include the incoming step id
        if(!is_incoming_clicked_button_back_button && is_saved_clicked_button_back_button)
          puts "HERE WE ARE IN THE SAVED BACK BUTTON"
          puts "ids #{ChatbotStep.find(user_chatbot_interaction.clicked_button_id.split("_").last.to_i).chatbot_button_replies.pluck(:id)} "
          puts "incoming id #{incoming_clicked_button_id}"

          #if it is a frst step after template button click then allow next step
          if user_chatbot_interaction.is_first_step_after_template_button_click
            user_chatbot_interaction.update(is_first_step_after_template_button_click: false)
            return false;
          end
          if(!ChatbotStep.find(user_chatbot_interaction.clicked_button_id.split("_").last.to_i).chatbot_button_replies.pluck(:id).include?(incoming_clicked_button_id.to_i))
            send_please_select_valid_option_message(to_phone_number, chatbot.select_valid_option)
            return true
          end
        end

        #if  both are not back buttons
        #you want to check if the chatbot_step of saved step bnutton replies includes the incoming step id
        if(!is_incoming_clicked_button_back_button && !is_saved_clicked_button_back_button)

          #if it is a frst step after template button click then allow next step
          if user_chatbot_interaction.is_first_step_after_template_button_click
            user_chatbot_interaction.update(is_first_step_after_template_button_click: false)
            return false;
          end

          saved_chabot_step = ChatbotStep.find_by(chatbot_button_reply_id: user_chatbot_interaction.clicked_button_id);

          if saved_chabot_step.present?
            if(!saved_chabot_step.chatbot_button_replies.pluck(:id).include?(incoming_clicked_button_id.to_i))
              send_please_select_valid_option_message(to_phone_number, chatbot.select_valid_option)
              return true
            end
          end
        end
      end
      
      return false
    end


    def find_chatbot_step(to_phone_number)
        result = Segment.joins("JOIN master_segments ON segments.master_segment_id = master_segments.id")
                        .joins("JOIN chatbots_master_segments ON master_segments.id = chatbots_master_segments.master_segment_id")
                        .joins("JOIN chatbots ON chatbots.id = chatbots_master_segments.chatbot_id")
                        .order("chatbots.created_at DESC")
                        .where("segments.mobile = ? AND chatbots.is_deleted = false AND master_segments.is_deleted = false AND segments.is_deleted = false", to_phone_number)
                        .select("chatbots.id AS chatbot_id, chatbots.created_at AS chatbot_created_at")
                        .first


      chatbot = result&.chatbot_id ? Chatbot.find(result.chatbot_id) : Chatbot.joins("LEFT JOIN chatbots_master_segments ON chatbots.id = chatbots_master_segments.chatbot_id")
                                       .where("chatbots_master_segments.master_segment_id IS NULL AND chatbots.is_deleted = false").first
      chatbot_step = chatbot.chatbot_steps.where(chatbot_button_reply_id: nil, is_deleted: false).first
      return chatbot_step
    end


    def send_message(to_phone_number, chatbot_step)

      if chatbot_step.nil?
        return
      end

      buttons_count = chatbot_step.chatbot_button_replies.where(is_deleted: false).count

      if buttons_count > 2 && chatbot_step.chatbot_button_reply_id.present?
        send_message_as_interactive_list(to_phone_number, chatbot_step)
        return;
      end

      buttons = chatbot_step.chatbot_button_replies.where(is_deleted: false).map { |button| { type: "reply", reply: { id: button.id, title: button.title } } }
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

      conversation_details = {
        text: {
          header: chatbot_step.header,
          body: chatbot_step.description,
          footer: chatbot_step.footer,
          buttons: buttons.map { |button| button[:reply][:title] }.join("\n")
        },
      }
      create_conversation(to_phone_number, conversation_details, true)
    end

    def send_message_as_interactive_list(to_phone_number, chatbot_step)
      
        rows = chatbot_step.chatbot_button_replies.where(is_deleted: false).map do |button|
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


      conversation_details = {
        text: {
          body: chatbot_step.description,
          buttons: rows.map { |button| button[:title] }.join("\n")
        }
      } 
      create_conversation(to_phone_number, conversation_details, true)
    end

    def get_message_back_payload(recieved_params)
      button_reply_id = recieved_params.dig('entry', 0, 'changes', 0, 'value', 'messages', 0, 'interactive', 'button_reply', "id")
      
      message_response_body = recieved_params.dig('entry', 0, 'changes', 0, 'value', 'messages', 0, 'text', 'body')

      list_reply_id = recieved_params.dig("entry", 0, "changes", 0, "value", "messages", 0, "interactive", "list_reply", "id")

      user_name = recieved_params.dig('entry', 0, 'changes', 0, 'value', 'contacts', 0, 'profile', 'name')

      button_payload = recieved_params.dig('entry', 0, 'changes', 0, 'value', 'messages', 0, 'button', 'payload')
     
      { button_reply_id: button_reply_id, message_response_body: message_response_body, list_reply_id: list_reply_id, user_name: user_name, button_payload: button_payload }
    end

    def send_mutlimedia_messages(to_phone_number, chatbot_step)
      mutlimedia_replies = chatbot_step.chatbot_multimedia_replies.where(is_deleted: false).order(:order)
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
      location_replies = chatbot_step.chatbot_location_replies.where(is_deleted: false).order(:order)
      location_replies.each do |location_reply|
        send_location_message(to_phone_number, location_reply.location_latitude, location_reply.location_longitude, location_reply.location_name, location_reply.location_address)
      end
    end

    def send_image_message(to_phone_number, image_url, file_caption)
      if (image_url.present?)
        WhatsappMessageService.send_image_message(to_phone_number, image_url, file_caption)
        create_conversation(to_phone_number, { image_url: image_url, file_caption: file_caption }, true)
      end
    end

    def send_document_message(to_phone_number, document_url, file_caption)
      if (document_url.present?)
        WhatsappMessageService.send_document_link(to_phone_number, document_url, file_caption)
        create_conversation(to_phone_number, { document_url: document_url, file_caption: file_caption }, true)
      end
    end

    def send_location_message(to_phone_number, latitude, longitude, location_name, location_description)
      if (latitude.present? && longitude.present?)
        WhatsappMessageService.send_location_message(to_phone_number, latitude, longitude, location_name, location_description)
        create_conversation(to_phone_number, { latitude: latitude, longitude: longitude, location_name: location_name, location_description: location_description }, true)
      end
    end

    def send_text_message(to_phone_number, text)
      if (text.present?)
        WhatsappMessageService.send_text_message(to_phone_number, text)
        create_conversation(to_phone_number, { text: { content: text } }, true)
      end
    end

    def create_conversation(to_phone_number, details, is_from_chat_bot)
      Conversation.create(
        mobile_number: to_phone_number,
        text: details[:text] || "",
        image_url: details[:image_url] || "",
        document_url: details[:document_url] || "", 
        file_caption: details[:file_caption] || "",
        latitude: details[:latitude] || "",
        longitude: details[:longitude] || "",
        location_name: details[:location_name] || "",
        location_description: details[:location_description] || "",
        is_from_chat_bot: is_from_chat_bot
      )
    end

    def send_please_select_valid_option_message(to_phone_number, message)
      WhatsappMessageService.send_text_message(to_phone_number, message)
      create_conversation(to_phone_number, { text: { content: message } }, true)
    end

    #check if the user is in a different chatbot from the saved interaction chatbot
    #and  the clicked button is in the same chatbot as the saved interaction chatbot
    #if it is then send all the messages of the latest chatbot first step
    def return_if_send_all_message_to_switched_chatbot_user(to_phone_number, latest_chatbot_step, incoming_reply_id)
      interaction = get_user_chatbot_interaction(to_phone_number)
      #if user in a different latest chatbot from the saved interaction chatbot
      #then send all the messages of the latest chatbot first step
      if interaction.present?
        if interaction.chatbot_id != latest_chatbot_step.chatbot.id
          is_incoming_clicked_button_back_button = incoming_reply_id.include?("BACK_")
          if is_incoming_clicked_button_back_button
            chatbot_step_of_incoming_clicked_button = ChatbotStep.find(incoming_reply_id.split("_").last.to_i)
          else
            chatbot_step_of_incoming_clicked_button = ChatbotButtonReply.find(incoming_reply_id).chatbot_step
          end
          if chatbot_step_of_incoming_clicked_button.chatbot_id == interaction.chatbot_id
            send_all_messages(to_phone_number, latest_chatbot_step)
            return true;
          else
            interaction.delete
          end
        end
      end
      return false
   end

   def save_segment_if_is_trigger(to_phone_number, button_reply, user_name)
    puts "button_reply.is_trigger: #{button_reply.is_trigger}"
    if (button_reply.is_trigger)
      master_segment = MasterSegment.find_by(name: button_reply.trigger_keyword, is_deleted: false)
      if master_segment.present?
        existing_segment = Segment.find_by(mobile: to_phone_number, master_segment_id: master_segment.id, is_deleted: false)
        puts "existing_segment: #{existing_segment}"
        if existing_segment.present?
          return
        end
        master_segment.segments.create(mobile: to_phone_number, person_name: user_name)
      end
    end
   end

  end
end

