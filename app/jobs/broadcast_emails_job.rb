# app/jobs/broadcast_emails_job.rb
require 'roo'

class BroadcastEmailsJob < ApplicationJob
  queue_as :default

  def perform(emails, subject, body_html, email_setting_id, attachment_urls = [], draft_id = nil)
    emails.each do |email|
      next if email.blank?
      next unless valid_email?(email)

      # Send the email asynchronously via deliver_later
      BroadcastMailer.broadcast_email(email, subject, body_html, email_setting_id, attachment_urls).deliver_now
    end
  end

  private

  # Simple email format validation
  def valid_email?(email)
    /\A[^@\s]+@[^@\s]+\z/.match?(email)
  end
end
