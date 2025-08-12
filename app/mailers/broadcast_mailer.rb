# app/mailers/broadcast_mailer.rb
class BroadcastMailer < ApplicationMailer
  include ActionView::Helpers::SanitizeHelper
  default from: 'globexdxb.noreply@gmail.com'

  def broadcast_email(to_email, subject, body_html)
    @body_html = body_html

    mail(to: to_email, subject: subject) do |format|
      format.html { render html: @body_html.html_safe }
      format.text { strip_tags(@body_html) }  # fallback plain text version
    end
  end
end
