class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)

    if user && user.authenticate(params[:password])
      log_in user
      redirect_to root_path, notice: t("success_login")
    else
      flash[:alert] = t("invalid_email_or_password")
      redirect_to login_path
    end
  end

  def destroy
    log_out
    redirect_to login_path, notice: t("success_logout")
  end

end
