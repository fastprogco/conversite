class ConversationsController < ApplicationController
  before_action :authorize_super_admin, only: [:index, :conversations_by_phone_number, :respond]
  def index
    @phone_numbers = Conversation.select(:mobile_number).distinct
  end

  def conversations_by_phone_number
    @page = params[:page] || 1
    @per_page = params[:per_page] || 10
    @conversations = Conversation.page(@page).per(@per_page)
    if params[:mobile_number].present?
      @conversations = @conversations.where(mobile_number: params[:mobile_number]).order(created_at: :desc)
    end
    render json: @conversations
  end

  def respond
    @to_phone_number = params[:phone_number]
    @message = params[:message]
    @file = params[:file]

    if(!@to_phone_number.present?)
      return redirect_to conversations_path, alert: "To phone number is required"
    end

    if(@file.present?)
      @file_type = @file.content_type
      @file_path = @file.path
      @file_name = @file.original_filename

      response = WhatsappMessageService.upload_media_message(@to_phone_number, @file_path, @file_type)
      parsed = JSON.parse(response)
      file_id = parsed["id"]

      if @file_type =="image/png" || @file_type == "image/jpeg"
        response = WhatsappMessageService.send_image_uploaded_message(@to_phone_number, file_id, @message)
        puts " this is the response: #{response.inspect}"
        if response.is_a?(Hash) && response.dig("error").present?
          error_message = response.dig(:body) || "Failed to send image message"
          return redirect_to conversations_path, alert: error_message
        else
          Conversation.create(mobile_number: @to_phone_number, text:{content: @message}, is_from_chat_bot: true)
          return redirect_to conversations_path, notice: "Image message sent successfully"
        end
      else
        response = WhatsappMessageService.send_pdf_uploaded_message(@to_phone_number,file_id, @message)
        if response.is_a?(Hash) && response.dig("error").present?
          error_message = response.dig(:body) || "Failed to send pdf message"
          return redirect_to conversations_path, alert: error_message
        else
          Conversation.create(mobile_number: @to_phone_number, text:{content: @message}, is_from_chat_bot: true, text:{content: "Pdf message sent successfully"})
          return redirect_to conversations_path, notice: "Pdf message sent successfully"
        end
      end
    else
      if @message.present?
        response = WhatsappMessageService.send_text_message(@to_phone_number, @message)
        if response.is_a?(Hash) && response.dig(:error).present?
          error_message = response.dig(:body) || "Failed to send text message"
          return redirect_to conversations_path, alert: error_message
        else
          Conversation.create(mobile_number: @to_phone_number, text:{content: @message}, is_from_chat_bot: true)
          return redirect_to conversations_path, notice: "Text message sent successfully"
        end 
      else
        return redirect_to conversations_path, alert: "Message is required"
      end
    end
  end
end
