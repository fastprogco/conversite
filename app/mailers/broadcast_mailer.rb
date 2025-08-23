# app/mailers/broadcast_mailer.rb
class BroadcastMailer < ApplicationMailer
  include ActionView::Helpers::SanitizeHelper
  default from: 'globexdxb.noreply@gmail.com'

  def broadcast_email(to_email, subject, body_html, email_setting_id, attachment_ids = [])
    @body_html = body_html

     # Attach files from ActionText draft
    attachment_ids.each do |signed_id|
      blob = ActiveStorage::Blob.find_signed(signed_id)
      attachments[blob.filename.to_s] = blob.download
    end


    # Fetch SMTP settings from EmailSetting
    setting = EmailSetting.find(email_setting_id)
    mail(
      to: to_email,
      subject: subject,
      delivery_method_options: {
        address: setting.smtp_host,
        port: setting.port,
        user_name: setting.user_name,
        password: setting.password,
        authentication: :plain,
        enable_starttls_auto: true
      }
    ) do |format|
      format.html { render html: @body_html.html_safe }
      format.text { strip_tags(@body_html) } # fallback plain text
    end
  end
end
