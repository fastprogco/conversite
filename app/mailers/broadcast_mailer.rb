class BroadcastMailer < ApplicationMailer
  include ActionView::Helpers::SanitizeHelper
  require "open-uri"

  default from: 'globexdxb.noreply@gmail.com'

  # attachment_files: array of hashes [{url: "...", filename: "..."}]
  def broadcast_email(to_email, subject, body_html, email_setting_id, attachment_files = [])
    @body_html = body_html

    attachment_files.each do |file|
      next unless file[:url] && file[:filename]
      begin
        attachments[file[:filename]] = URI.open(file[:url]).read
      rescue => e
        Rails.logger.error "Failed to attach file from URL #{file[:url]}: #{e.message}"
      end
    end

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
      format.text { strip_tags(@body_html) }
    end
  end
end
