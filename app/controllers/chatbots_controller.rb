class ChatbotsController < ApplicationController
    before_action :authorize_super_admin, only: [:index, :new, :create, :edit, :update, :destroy]

    def index
        @page = params[:page] || 1
        @chatbots = Chatbot.where(is_deleted: false).order(created_at: :desc).page(@page).per(10)
    end

    def new
        @chatbot = Chatbot.new
    end

    def create
        @chatbot = Chatbot.new(chatbot_params)
        @chatbot.created_by = current_user
        if chatbot_params[:is_default] == "1"
            @chatbot.is_default = true
        else
            @chatbot.is_default = false
        end
        if @chatbot.save
            associate_master_segments(@chatbot, true)
            redirect_to chatbots_path, notice: 'Chatbot was successfully created.'
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        @chatbot = Chatbot.find(params[:id])
    end

    def update
        @chatbot = Chatbot.find(params[:id])

        if chatbot_params[:is_default] == "1"
            @chatbot.is_default = true
        else
            @chatbot.is_default = false
        end
        if @chatbot.update(chatbot_params)
            associate_master_segments(@chatbot, true)
            redirect_to chatbots_path, notice: 'Chatbot was successfully updated.'
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @chatbot = Chatbot.find(params[:id])
        @chatbot.deleted_by_id = current_user.id
        @chatbot.is_deleted = true
        if @chatbot.save
            @chatbot.chatbot_steps.update_all(deleted_by_id: current_user.id, is_deleted: true)
            redirect_to chatbots_path, notice: 'Chatbot with all steps was successfully deleted.'
        else
           redirect_to chatbots_path, alert: @chatbot.errors.full_messages.join(', ')
        end
    end

    private
    def chatbot_params
        params.require(:chatbot).permit(:name, :description, :select_valid_option, :is_default,:optout_success_message, master_segment_ids: [])
    end

    #for each clicked master segment checkbox create the associated join in entry in the join table
    def associate_master_segments(chatbot, is_update = false)
        puts "here is master segment ids #{chatbot_params[:master_segment_ids]}"
        if is_update
            chatbot.master_segments.destroy_all
        end
        chatbot_params[:master_segment_ids].reject(&:blank?).each do |segment_id|
            chatbot.master_segments << MasterSegment.find(segment_id)
        end
    end
    

end
