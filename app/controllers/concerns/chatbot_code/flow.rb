module ChatbotCode
  module Flow
    extend ActiveSupport::Concern

    def start(to_phone_number, params)
      puts "starting flow"
   # Determine the table dynamically in Ruby


        # Join master_segments and select table_type_id
        result = Segment.joins("JOIN master_segments ON segments.master_segment_id = master_segments.id")
          .joins("JOIN chatbots ON chatbots.master_segment_id = master_segments.id")
          .joins("LEFT JOIN masters ON masters.id = segments.table_id")
          .order("chatbots.created_at DESC")
          .where("masters.mobile = ?", to_phone_number)
          .select("chatbots.id AS chatbot_id, chatbots.created_at AS chatbot_created_at")
          .first


      chatbot = result.chatbot_id ? Chatbot.find(result.chatbot_id) : Chatbot.find_by(master_segment_id: nil)
      send_message(to_phone_number, chatbot)
    end

    def send_message(to_phone_number, chatbot)
      chatbot_step = chatbot.chatbot_steps.first
      button_1 = chatbot_step.chatbot_button_replies.first.title
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
            buttons: [
                  {
                  type: "reply",
                  reply: {
                      id: chatbot_step.chatbot_button_replies.first.id,
                      title: button_1
                      }
                  },
              ]
          }
        }
      response = WhatsappMessageService.send_interactive_message(to_phone_number, interactive_payload  )
    end
  end
end
