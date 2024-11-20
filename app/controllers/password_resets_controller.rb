class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user
      user.generate_password_reset
      UserMailer.reset_password_instructions(user).deliver_now
      redirect_to login_user_path, notice: t("check_email_to_reset_password")
    else
      flash.now[:alert] = t("email_not_found")
      render :new
    end
  end

  def edit
    @user = User.find_by(reset_password_token: params[:token])
    redirect_to new_password_reset_path, alert: t("invalid_token") unless @user&.password_token_valid?
  end

  def update
    @user = User.find_by(reset_password_token: params[:token])
    if @user&.password_token_valid? && @user.reset_password!(params[:password])
      redirect_to login_user_path, notice: t("password_reset_please_login")
    else
      flash.now[:alert] = t("password_reset_token_invalid_or_expired")
      render :edit
    end
  end
end
