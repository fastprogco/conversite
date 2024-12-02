class ChatbotButtonRepliesController < ApplicationController
    before_action :set_chatbot, only: [:new, :edit, :update, :create]
    before_action :set_chatbot_step, only: [:new, :edit, :update, :create]

    def new
        @chatbot_button_reply = ChatbotButtonReply.new
    end

    def create
        @chatbot_button_reply = ChatbotButtonReply.new(chatbot_button_reply_params.except(:action_type_id))
        @chatbot_button_reply.chatbot_step = @chatbot_step
        @chatbot_button_reply.chatbot = @chatbot
        @chatbot_button_reply.added_by_id = current_user.id
        @chatbot_button_reply.added_on = DateTime.now
        @chatbot_button_reply.action_type_id = chatbot_button_reply_params[:action_type_id].to_i
        if @chatbot_button_reply.save
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Reply option added successfully", status: :see_other
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        @chatbot_button_reply = ChatbotButtonReply.find(params[:id])
    end

    def update
        @chatbot_button_reply = ChatbotButtonReply.find(params[:id])
        @chatbot_button_reply.edited_by = current_user
        @chatbot_button_reply.edited_on = DateTime.now
        @chatbot_button_reply.action_type_id = chatbot_button_reply_params[:action_type_id].to_i
        if @chatbot_button_reply.update(chatbot_button_reply_params.except(:action_type_id))
            redirect_to chatbot_step_path(@chatbot, @chatbot_step), notice: "Reply option updated successfully", status: :see_other
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @chatbot_button_reply = ChatbotButtonReply.find(params[:id])
        @chatbot_button_reply.deleted_by = current_user
        @chatbot_button_reply.deleted_on = DateTime.now
        @chatbot_button_reply.is_deleted = true
        @chatbot_button_reply.save
        redirect_to chatbot_step_path(@chatbot, @chatbot_step), notice: "Reply option deleted successfully", status: :see_other
    end

    private

    def set_chatbot
        @chatbot = Chatbot.find(params[:chatbot_id])
    end

    def set_chatbot_step
        @chatbot_step = ChatbotStep.find(params[:chatbot_step_id])
    end

    def chatbot_button_reply_params
        params.require(:chatbot_button_reply).permit(:title, :order, :action_type_id)
    end
end
