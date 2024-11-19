class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.confirmation_instructions(@user).deliver_now
      redirect_to root_path, notice: t("user_created_confirm_email_please")
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  
  def confirm_email
    @user_id_from_params = params[:user_id]
    @user_already_confirmed = User.where(id: @user_id_from_params).where.not(email_confirmed_at: nil).exists?
    if @user_already_confirmed
      redirect_to login_admin_path, alert: t("email_already_confirmed_please_login")
      return;
    end
    user = User.find_by(email_confirmation_token: params[:token])
    if user.present? && user.email_confirmation_token.present?
      user.confirm_email!
      if !user.email_confirmation_token
       redirect_to login_user_path, notice: t("email_confirmed_login")
      else
        flash.now[:alert] = t("could_not_confirm_email")
      end
    else
      redirect_to login_user_path, alert: t("invalid_confirmation_token")
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :phone, :role)
  end
end