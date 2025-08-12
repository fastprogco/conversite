class UserMailer < ApplicationMailer
  default from: 'globexdxb.noreply@gmail.com'

  def confirmation_instructions(user)
    @user = user
    @url = confirm_email_url(token: @user.email_confirmation_token, user_id: @user.id)
    mail(to: @user.email, subject: t("confirmation_instruction"))
  end

  def reset_password_instructions(user)
    @user = user
    @url  = edit_password_reset_url(token: @user.reset_password_token)
    mail(to: @user.email, subject: t("reset_password_instructions"))
  end
end
