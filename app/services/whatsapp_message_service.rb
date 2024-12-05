require 'http'

class WhatsappMessageService
  class << self
    attr_accessor :business_account_id, :url, :access_token

    def send_interactive_message(to_phone_number, interactive_message_object)

      response = HTTP.auth("Bearer #{access_token}").post("#{url}/messages", json: {
        messaging_product: 'whatsapp',
        to: to_phone_number,
        type: 'interactive',
        interactive: interactive_message_object
      })

      handle_response(response)
    rescue HTTP::Error => e
      { error: e.message }
    end

    def send_image_message(to_phone_number, link_to_image, image_caption_text)
      message = {
        messaging_product: "whatsapp",
        recipient_type: "individual",
        to: to_phone_number,
        type: "image",
        image: {
          link: link_to_image,
          caption: image_caption_text
        }
      }
      response = HTTP.auth("Bearer #{access_token}").post("#{url}/messages", json: message)

      handle_response(response)
    rescue HTTP::Error => e
      { error: e.message }
    end

    def send_text_message(to_phone_number, text_body, text_link="")
        message = {
                    messaging_product: "whatsapp",
                    recipient_type: "individual",
                    to: to_phone_number,
                    type: "text",
                    text: {
                            preview_url: text_link,
                            body: text_body
                        }
                    }
        response = HTTP.auth("Bearer #{access_token}").post("#{url}/messages", json: message)

        puts "response is here #{response}"
        handle_response(response)
    rescue HTTP::Error => e
    { error: e.message }
    end

    def send_location_request(to_phone_number, text_body)
      message = {
                  messaging_product: "whatsapp",
                  recipient_type: "individual",
                  type: "interactive",
                  to: to_phone_number,
                  interactive: {
                    type: "location_request_message",
                    body: {
                      text: text_body
                    },
                    action: {
                      name: "send_location"
                    }
                  }
                }
      response = HTTP.auth("Bearer #{access_token}").post("#{url}/messages", json: message)

      handle_response(response)
  rescue HTTP::Error => e
  { error: e.message }
  end

   def send_document_link(to_phone_number, document_link, filename)
      message = {
                  messaging_product: "whatsapp",
                  recipient_type: "individual",
                  to: to_phone_number,
                  type: "document",
                  document: {
                    link: document_link,
                    filename: filename
                    
                  }
                }
      response = HTTP.auth("Bearer #{access_token}").post("#{url}/messages", json: message)

        handle_response(response)
    rescue HTTP::Error => e
    { error: e.message }
    end

      def upload_media_message(to_phone_number, file_path, file_type)
        url = "#{@url}/media"

          form_data = {
            file: HTTP::FormData::File.new(file_path, filename: File.basename(file_path), content_type: file_type),
            type: file_type,
            messaging_product: 'whatsapp'  # Include the messaging_product parameter
          }

          response = HTTP.auth("Bearer #{@access_token}")
         .post(url, form: form_data)

        return response;
      rescue HTTP::Error => e
        { error: e.message }
      end


      def send_image_uploaded_message(to_phone_number, media_id, caption = "")
      message = {
                  messaging_product: "whatsapp",
                  recipient_type: "individual",
                  to: to_phone_number,
                  type: "image",
                  image: {
                    id: media_id,
                    caption: caption
                  }
                }
      response = HTTP.auth("Bearer #{access_token}").post("#{url}/messages", json: message)

        handle_response(response)
    rescue HTTP::Error => e
    { error: e.message }
    end

     def send_pdf_uploaded_message(to_phone_number, media_id, caption = "")
      message = {
                  messaging_product: "whatsapp",
                  recipient_type: "individual",
                  to: to_phone_number,
                  type: "document",
                  document: {
                    id: media_id,
                    caption: caption
                  }
                }
      response = HTTP.auth("Bearer #{access_token}").post("#{url}/messages", json: message)

      handle_response(response)
    rescue HTTP::Error => e
    { error: e.message }
    end

    def send_interactive_list_message(to_phone_number, interactive_list_message_object)
      message = {
        messaging_product: 'whatsapp',
        to: to_phone_number,
        type: 'interactive',
        interactive: interactive_list_message_object
      }
      
      response = HTTP.auth("Bearer #{access_token}").post("#{url}/messages", json: message)

      handle_response(response)
    end

    def retrieve_message_image_from_response(image_id)
      url = "https://graph.facebook.com/v20.0/#{image_id}"

      puts "here is the url #{url}"
      response = HTTP.auth("Bearer #{@access_token}").get(url)

      if response.status.success?
        parsed_body = JSON.parse(response.body.to_s)
        url = parsed_body.dig("url")
        mime_type = parsed_body.dig("mime_type")
        return url, mime_type
      else
        error_details = {
          error: "HTTP #{response.status.code}: #{response.status.reason}",
          body: response.body.to_s,
          headers: response.headers.to_h
        }
        Rails.logger.error("Failed to retrieve image: #{error_details}")
        error_details
      end
    end

    def send_mobile_confirmation_template(to_phone_number, confirmation_code)
       template_body = [
        {
          "type": "body",
          "parameters": [
            {
              "type": "text",
              "text": confirmation_code
            }
          ]
        },
        {
          "type": "button",
          "sub_type": "url",
          "index": "0",
          "parameters": [
            {
              "type": "text",
              "text": confirmation_code
            }
          ]
        }
      ]
      send_text_message_template(to_phone_number, "mobile_confirmation", "ar", template_body)
    end

    def send_text_message_template(to_phone_number, template_name, language_code, parameters)
      message = {
        messaging_product: "whatsapp",
        to: to_phone_number,
        type: "template",
        template: {
          name: template_name,
          language: {
            code: language_code
          },
          components: parameters
        }
      }

      response = HTTP.auth("Bearer #{access_token}").post("#{url}/messages", json: message)

      handle_response(response)
    rescue HTTP::Error => e
      { error: e.message }
    end

    def send_location_message(to_phone_number, latitude, longitude, location_name = nil, location_description = nil)
      message = {
        messaging_product: "whatsapp",
        to: to_phone_number,
        type: "location",
        location: {
          latitude: latitude,
          longitude: longitude,
          name: location_name,
          address: location_description
        }
      }

      response = HTTP.auth("Bearer #{access_token}").post("#{url}/messages", json: message)

      handle_response(response)
    rescue HTTP::Error => e
      { error: e.message }
    end

    private

    def handle_response(response)
      if response.status.success?
        if response.content_type.mime_type == 'application/json'
          response.parse
        else
          { error: "Unexpected MIME type: #{response.content_type.mime_type}" }
        end
      else
        error_details = {
          error: "HTTP #{response.status.code}: #{response.status.reason}",
          body: response.body.to_s,
          headers: response.headers.to_h
        }
        Rails.logger.error("Failed to send WhatsApp message: #{error_details}")
        error_details
      end
    end
  end

  #self.business_account_id = "301936199680427"
  #self.access_token = "EAAFJEwRiEhsBO9IZCZBAOBaBEh2nzOxvax3zFQIlA9B7dL7WA7ZBF3r3RALKy19CufMzbE7fS75DlFk5tFeZC7T2ZA1aP8D4CoJWX0rdbsalHDyMvMUsWiWpX4HZB0oqtb84061ceVwwV0U2XVAEoOuZAZCI45HAhiaIONx2BIDZCsL6gkLQjOekZCXClhJOb6bblExQZDZD"
  self.business_account_id = "111633038467297"
  self.url = "https://graph.facebook.com/v20.0/#{business_account_id}"
  self.access_token = "EAAPDdDpQ0DwBO5ptclqW6YTJ0DOlJ6lvOnC3LkK7ANkFxMn4XdUU5BRC0f6p817g4pZCjtqU0ccV81VU0IPKb9XyHLcLZCtmTDnTvjPKZCD3ZAfdnRmZBpgKWhpNM0BZBdaoUUIOKtqGcHgEO0EhD8aN186ZAov1IXryC1zhZBntqtzmT9R0dSxaV8J4PrdZAwRchEUuVcW8jF1ZCBAgrS"

 
end