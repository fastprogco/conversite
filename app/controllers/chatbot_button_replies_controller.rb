class ChatbotButtonRepliesController < ApplicationController
    before_action :set_chatbot, only: [:new, :edit, :update, :create, :destroy]
    before_action :set_chatbot_step, only: [:new, :edit, :update, :create, :destroy]
    
    before_action :authorize_super_admin, only: [:new, :create, :edit, :update, :destroy]

    def new
        @chatbot_button_reply = ChatbotButtonReply.new
    end

    def create
        @chatbot_button_reply = ChatbotButtonReply.new(chatbot_button_reply_params.except(:action_type_id))
        
        if chatbot_button_reply_params[:is_trigger] == "1"
            existing_master_segment = MasterSegment.find_by(name:@chatbot_button_reply.trigger_keyword.downcase, is_deleted: false)
            if existing_master_segment.present?
                redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Trigger keyword already exists", status: :see_other
            else
                @master_segment = MasterSegment.new(name:@chatbot_button_reply.trigger_keyword.downcase, added_by_id: current_user.id)
                if @master_segment.save
                   save_button_reply
                else
                    redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), alert: "Master segment not saved: " + @master_segment.errors.full_messages.join(", ")
                end
            end
        else
            save_button_reply
        end
    end

    def edit
        @chatbot_button_reply = ChatbotButtonReply.find(params[:id])
    end

    def update
        @chatbot_button_reply = ChatbotButtonReply.find(params[:id])
        existing_master_segment = MasterSegment.find_by(name:chatbot_button_reply_params[:trigger_keyword].downcase, is_deleted: false)
        
        is_now_trigger = chatbot_button_reply_params[:is_trigger] == "1"
        was_previously_trigger = @chatbot_button_reply.is_trigger
        previous_trigger_keyword = @chatbot_button_reply.trigger_keyword
        current_trigger_keyword = chatbot_button_reply_params[:trigger_keyword].downcase

        if existing_master_segment.present?
            if was_previously_trigger
                if previous_trigger_keyword != current_trigger_keyword && current_trigger_keyword.present?
                    redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Trigger keyword already exists", status: :see_other
                    return;
                end
            end
        end

        if is_now_trigger
            if previous_trigger_keyword != current_trigger_keyword
                @master_segment = MasterSegment.new(name:current_trigger_keyword, added_by_id: current_user.id)
                if !@master_segment.save
                    redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), alert: "Master segment not saved: " + @master_segment.errors.full_messages.join(", ")
                    return;
                end
            end
        else
            if existing_master_segment.present? && was_previously_trigger
                existing_master_segment.update(is_deleted: true)
            end
        end
        update_button_reply
    end

    def destroy
        @chatbot_button_reply = ChatbotButtonReply.find(params[:id])
        @chatbot_button_reply.deleted_by = current_user
        @chatbot_button_reply.is_deleted = true
        @chatbot_button_reply.save
        redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Reply option deleted successfully", status: :see_other
    end

    private

    def set_chatbot
        @chatbot = Chatbot.find(params[:chatbot_id])
    end

    def set_chatbot_step
        @chatbot_step = ChatbotStep.find(params[:chatbot_step_id])
    end

    def chatbot_button_reply_params
        params.require(:chatbot_button_reply).permit(:title, :order, :action_type_id, :is_trigger, :trigger_keyword)
    end

    def update_button_reply
        @chatbot_button_reply.edited_by = current_user
        @chatbot_button_reply.edited_on = DateTime.now.utc
        @chatbot_button_reply.action_type_id = chatbot_button_reply_params[:action_type_id].to_i
        if @chatbot_button_reply.update(chatbot_button_reply_params.except(:action_type_id))
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Reply option updated successfully", status: :see_other
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def save_button_reply
        @chatbot_button_reply.chatbot_step = @chatbot_step
        @chatbot_button_reply.chatbot = @chatbot
        @chatbot_button_reply.added_by_id = current_user.id
        @chatbot_button_reply.added_on = DateTime.now.utc
        @chatbot_button_reply.action_type_id = chatbot_button_reply_params[:action_type_id].to_i
        if @chatbot_button_reply.save
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step), notice: "Reply option added successfully", status: :see_other
        else
            render :new, status: :unprocessable_entity
        end
    end
end
