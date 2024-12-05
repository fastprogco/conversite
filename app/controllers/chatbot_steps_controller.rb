class ChatbotStepsController < ApplicationController
    before_action :set_chatbot
    before_action :set_chatbot_step, only: [:edit, :update, :destroy]

    def index
    end

    def new
        @chatbot_step = ChatbotStep.new
        @chatbot_button_reply_id = params[:chatbot_button_reply_id]
        @previous_chatbot_step_id = params[:previous_chatbot_step_id]
    end

    def create
        @chatbot_step = @chatbot.chatbot_steps.build(chatbot_step_params)
        @chatbot_step.created_by = current_user
        @chatbot_step.previous_chatbot_step = ChatbotStep.find(params[:previous_chatbot_step_id]) if params[:previous_chatbot_step_id].present?
        @chatbot_step.chatbot_button_reply_id = ChatbotButtonReply.find(params[:chatbot_button_reply_id]).id if params[:chatbot_button_reply_id].present?
        if @chatbot_step.save
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Chatbot step created successfully"
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        @chatbot_step = ChatbotStep.find(params[:id])
        @previous_chatbot_step_id = params[:previous_chatbot_step_id]
    end

    def update
        @chatbot_step = ChatbotStep.find(params[:id])
        @chatbot_step.edited_by = current_user
        if @chatbot_step.update(chatbot_step_params)
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Chatbot step updated successfully"
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @chatbot_step = ChatbotStep.find(params[:id])
        @chatbot_step.deleted_by = current_user
        @chatbot_step.is_deleted = true
        @chatbot_step.save
        redirect_to chatbots_path, notice: "Chatbot step deleted successfully"
    end

    private

    def set_chatbot
        @chatbot = Chatbot.find(params[:chatbot_id])
    end

    def set_chatbot_step
        @chatbot_step = @chatbot.chatbot_steps.find(params[:id])
    end

    def chatbot_step_params
        params.permit(:header, :description, :footer, :list_button_caption, :previous_chatbot_step_id, :chatbot_id, :chatbot_button_reply_id)
    end
end
