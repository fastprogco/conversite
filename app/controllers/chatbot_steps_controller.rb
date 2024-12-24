class ChatbotStepsController < ApplicationController
    before_action :set_chatbot
    before_action :set_chatbot_step, only: [:edit, :update, :destroy]
    before_action :authorize_super_admin, only: [:index, :new, :create, :edit, :update, :destroy]

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


        get_leading_button_reply
        if !check_existing_and_save_end_chatbot_step_master_segment(chatbot_step_params[:end_chabot])
            update_leading_button_reply_to_trigger
        else
            if !params[:chatbot_button_reply_id]
                 redirect_to new_chatbot_chatbot_step_path(@chatbot, previous_chatbot_step_id: @chatbot_step.previous_chatbot_step_id, chatbot_button_reply_id: @chatbot_step.chatbot_button_reply_id), alert: "Chatbot step creation failed , master segment already exists"
                 return
            end
        end

        if @chatbot_step.save
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step, previous_chatbot_step_id: @chatbot_step.previous_chatbot_step_id, chatbot_button_reply_id: @chatbot_step.chatbot_button_reply_id), notice: "Chatbot step created successfully"
        else
            redirect_to new_chatbot_chatbot_step_path(@chatbot, previous_chatbot_step_id: @chatbot_step.previous_chatbot_step_id, chatbot_button_reply_id: @chatbot_step.chatbot_button_reply_id), alert: "Chatbot step creation failed #{@chatbot_step.errors.full_messages.join(', ')}"
        end
    end

    def edit
        @chatbot_step = ChatbotStep.find(params[:id])
        @previous_chatbot_step_id = params[:previous_chatbot_step_id]
    end

    def update
        @chatbot_step = ChatbotStep.find(params[:id])

        if !check_trigger_master_segment_name_change(chatbot_step_params)
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step, previous_chatbot_step_id: @chatbot_step.previous_chatbot_step_id, chatbot_button_reply_id: @chatbot_step.chatbot_button_reply_id), alert: "You are not allowed to change the trigger master segment name"
            return;
        end

        get_leading_button_reply
        if !check_existing_and_save_end_chatbot_step_master_segment(chatbot_step_params[:end_chabot])
            update_leading_button_reply_to_trigger
        else
            if !params[:chatbot_button_reply_id]
                 redirect_to new_chatbot_chatbot_step_path(@chatbot, previous_chatbot_step_id: @chatbot_step.previous_chatbot_step_id, chatbot_button_reply_id: @chatbot_step.chatbot_button_reply_id), alert: "Chatbot step update failed , master segment already exists"
                 return
            end
        end

        @chatbot_step.edited_by = current_user
        if @chatbot_step.update(chatbot_step_params)
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step, previous_chatbot_step_id: @chatbot_step.previous_chatbot_step_id, chatbot_button_reply_id: @chatbot_step.chatbot_button_reply_id), notice: "Chatbot step updated successfully"
        else
            redirect_to edit_chatbot_chatbot_step_path(@chatbot, @chatbot_step, previous_chatbot_step_id: @chatbot_step.previous_chatbot_step_id, chatbot_button_reply_id: @chatbot_step.chatbot_button_reply_id), alert: "Chatbot step update failed #{@chatbot_step.errors.full_messages.join(', ')}"
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
        params.require(:chatbot_step).permit(:header, :description, :footer, :list_button_caption, :previous_chatbot_step_id, :chatbot_id, :chatbot_button_reply_id, :end_chabot, :end_chabot_reply, :has_go_back_to_main, :go_back_to_main_button_title, :trigger_master_segment_name)
    end

    def get_leading_button_reply
        if @chatbot_step.chatbot_button_reply_id.present?
            @chatbot_button_reply = ChatbotButtonReply.find(@chatbot_step.chatbot_button_reply_id);
        end
    end

    def update_leading_button_reply_to_trigger
        if @chatbot_step.trigger_master_segment_name.present?
            if @chatbot_button_reply.present? 
                @chatbot_button_reply.update(is_trigger: true, trigger_keyword: @chatbot_step.trigger_master_segment_name);
            end
        end
    end

    def check_existing_and_save_end_chatbot_step_master_segment(is_end_chatbot_step)
        if is_end_chatbot_step
            existing_msater_segment = MasterSegment.find_by(name: @chatbot_step.trigger_master_segment_name, is_deleted: false);
            if existing_msater_segment.present?
                return true;
            else
                chain_of_steps = @chatbot_button_reply.chain_of_steps
                @master_segment = MasterSegment.create(name: @chatbot_step.trigger_master_segment_name, chain_of_steps: chain_of_steps, added_by: current_user);
                return false;
            end
        end
        
    end

    def check_trigger_master_segment_name_change(chatbot_step_params)
        if chatbot_step_params[:end_chabot] == "1" 
            if @chatbot_step.trigger_master_segment_name != chatbot_step_params[:trigger_master_segment_name] && @chatbot_step.trigger_master_segment_name.present?
                return false;
            end
        end
        return true;
    end


end
