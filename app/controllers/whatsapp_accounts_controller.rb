class WhatsappAccountsController < ApplicationController
    before_action :set_whatsapp_account, only: [:edit, :update, :destroy]
    before_action :authorize_super_admin, only: [:index, :new, :create, :edit, :update, :destroy]

    def index
        @page = params[:page] || 1
        @whatsapp_accounts = WhatsappAccount.where(is_deleted: false, added_by: current_user).page(@page).per(10)
    end

    def new
        @whatsapp_account = WhatsappAccount.new
    end

    def create
        @whatsapp_account = WhatsappAccount.new(whatsapp_account_params)
        @whatsapp_account.added_by = current_user
        if @whatsapp_account.save
            redirect_to whatsapp_accounts_path, notice: 'Whatsapp account was successfully created.'
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        @whatsapp_account.edited_by = current_user
        if @whatsapp_account.update(whatsapp_account_params)
            redirect_to whatsapp_accounts_path, notice: 'Whatsapp account was successfully updated.'
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @whatsapp_account.deleted_by = current_user
        @whatsapp_account.is_deleted = true
        if @whatsapp_account.save
            redirect_to whatsapp_accounts_path, notice: 'Whatsapp account was successfully deleted.'
        else
            redirect_to whatsapp_accounts_path, alert: 'Failed to delete Whatsapp account.'
        end
    end

    private

    def set_whatsapp_account
        @whatsapp_account = WhatsappAccount.find(params[:id])
    end

    def whatsapp_account_params
        params.require(:whatsapp_account).permit(:name, :whatsapp_mobile_number, :app_id, :phone_number_id, :whatsapp_business_account_id, :token, :webhook_version)
    end
end