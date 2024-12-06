class ChatbotsController < ApplicationController
    before_action :authorize_super_admin, only: [:index, :new, :create, :edit, :update, :destroy]

    def index
        @page = params[:page] || 1
        @chatbots = Chatbot.includes(:master_segment).order(created_at: :desc).page(@page).per(10)
    end

    def new
        @chatbot = Chatbot.new
    end

    def create
        @chatbot = Chatbot.new(chatbot_params)
        @chatbot.created_by = current_user
        if @chatbot.save
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
        if @chatbot.update(chatbot_params)
            redirect_to chatbots_path, notice: 'Chatbot was successfully updated.'
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @chatbot = Chatbot.find(params[:id])
        @chatbot.deleted_by = current_user
        @chatbot.is_deleted = true
        @chatbot.chatbot_steps.update_all(deleted_by: current_user, is_deleted: true)
        @chatbot.save
        redirect_to chatbots_path, notice: 'Chatbot with all steps was successfully deleted.'
    end

    private
    def chatbot_params
        params.require(:chatbot).permit(:name, :description, :master_segment_id)
    end

end
