class ChatbotLocationRepliesController < ApplicationController
    before_action :set_chatbot, only: [:new, :edit, :update, :create, :destroy]
    before_action :set_chatbot_step, only: [:new, :edit, :update, :create, :destroy]
    before_action :set_chatbot_location_reply, only: [:edit, :update, :destroy]

    before_action :authorize_super_admin, only: [:new, :create, :edit, :update, :destroy]

    def new
        @chatbot_location_reply = ChatbotLocationReply.new
    end

    def create
        @chatbot_location_reply = ChatbotLocationReply.new(chatbot_location_reply_params)
        @chatbot_location_reply.chatbot_step = @chatbot_step
        @chatbot_location_reply.chatbot = @chatbot
        @chatbot_location_reply.added_by_id = current_user.id
        @chatbot_location_reply.added_on = DateTime.now.utc
        if @chatbot_location_reply.save
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Reply option added successfully", status: :see_other
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        @chatbot_location_reply.edited_by = current_user
        @chatbot_location_reply.edited_on = DateTime.now.utc
        if @chatbot_location_reply.update(chatbot_location_reply_params)
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Reply option updated successfully", status: :see_other
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @chatbot_location_reply.deleted_by = current_user
        @chatbot_location_reply.is_deleted = true
        @chatbot_location_reply.save
        redirect_to chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Reply option deleted successfully", status: :see_other
    end

    private

    def set_chatbot
        @chatbot = Chatbot.find(params[:chatbot_id])
    end

    def set_chatbot_step
        @chatbot_step = ChatbotStep.find(params[:chatbot_step_id])
    end

    def chatbot_location_reply_params
        params.permit(:location_name, :location_address, :location_latitude, :location_longitude, :order)
    end

    def set_chatbot_location_reply
        @chatbot_location_reply = ChatbotLocationReply.find(params[:id])
    end
end
