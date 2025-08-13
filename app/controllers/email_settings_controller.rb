class EmailSettingsController < ApplicationController
  before_action :set_email_setting, only: %i[ show edit update destroy ]

  # GET /email_settings or /email_settings.json
  def index
    @page = params[:page] || 1
    @email_settings = EmailSetting.where(is_deleted: false, added_by: current_user).page(@page).per(10)
  end

  # GET /email_settings/1 or /email_settings/1.json
  def show
  end

  # GET /email_settings/new
  def new
    @email_setting = EmailSetting.new
  end

  # GET /email_settings/1/edit
  def edit
  end

  # POST /email_settings or /email_settings.json
  def create
    @email_setting = EmailSetting.new(email_setting_params)
    @email_setting.added_by = current_user
    respond_to do |format|
      if @email_setting.save
        format.html { redirect_to email_settings_path, notice: "Email setting was successfully created." }
        format.json { render :show, status: :created, location: @email_setting }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @email_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /email_settings/1 or /email_settings/1.json
  def update
    respond_to do |format|
      @email_setting.edited_by = current_user
      if @email_setting.update(email_setting_params)
        format.html { redirect_to email_settings_path, notice: "Email setting was successfully updated." }
        format.json { render :show, status: :ok, location: @email_setting }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @email_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_settings/1 or /email_settings/1.json
  def destroy
    @email_setting.soft_delete(current_user)

    respond_to do |format|
      format.html { redirect_to email_settings_path, status: :see_other, notice: "Email setting was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_email_setting
      @email_setting = EmailSetting.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def email_setting_params
      params.require(:email_setting).permit(:name, :smtp_host, :port, :email_address, :user_name, :password)
    end
end
