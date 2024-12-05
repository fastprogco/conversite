class ChatbotMultimediaRepliesController < ApplicationController

    before_action :set_chatbot, only: [:new, :edit, :update, :create, :destroy]
    before_action :set_chatbot_step, only: [:new, :edit, :update, :create, :destroy]
    before_action :set_chatbot_multimedia_reply, only: [:edit, :update, :destroy]
    def new
        @chatbot_multimedia_reply = ChatbotMultimediaReply.new
    end

    def create
        @chatbot_multimedia_reply = ChatbotMultimediaReply.new(chatbot_multimedia_reply_params.merge(media_type_id: chatbot_multimedia_reply_params[:media_type_id].to_i))
        @chatbot_multimedia_reply.chatbot_step = @chatbot_step
        @chatbot_multimedia_reply.chatbot = @chatbot
        @chatbot_multimedia_reply.added_by_id = current_user.id
        @chatbot_multimedia_reply.added_on = DateTime.now.utc
        if @chatbot_multimedia_reply.save
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Multimedia reply added successfully", status: :see_other
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        @chatbot_multimedia_reply = ChatbotMultimediaReply.find(params[:id])
    end

    def update
        @chatbot_multimedia_reply.edited_by_id = current_user.id
        @chatbot_multimedia_reply.edited_on = DateTime.now.utc
        if @chatbot_multimedia_reply.update(chatbot_multimedia_reply_params.merge(media_type_id: chatbot_multimedia_reply_params[:media_type_id].to_i))
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Multimedia reply updated successfully", status: :see_other
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @chatbot_multimedia_reply = ChatbotMultimediaReply.find(params[:id])
        @chatbot_multimedia_reply.deleted_by_id = current_user.id
        @chatbot_multimedia_reply.is_deleted = true
        @chatbot_multimedia_reply.save
        redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Multimedia reply deleted successfully", status: :see_other
    end

    private

    def set_chatbot
        @chatbot = Chatbot.find(params[:chatbot_id])
    end

    def set_chatbot_step
        @chatbot_step = ChatbotStep.find(params[:chatbot_step_id])
    end

    def set_chatbot_multimedia_reply
        @chatbot_multimedia_reply = ChatbotMultimediaReply.find(params[:id])
    end

    def chatbot_multimedia_reply_params
        params.permit(:media_type_id, :text_body, :file_caption, :order, :file)
    end

end
