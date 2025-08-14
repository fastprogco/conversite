class EmailBroadcastsController < ApplicationController
  before_action :authorize_super_admin, only: [ :new, :create]

  def new
    @email_broadcast_draft = EmailBroadcastDraft.new
  end
def create
  uploaded_file = params[:file]

  if params[:template_id].present?
    template = EmailTemplate.find_by(id: params[:template_id])
    if template.nil?
      redirect_to new_email_broadcast_path, alert: "Selected template not found."
      return
    end

    subject = params[:subject].presence || template.title # Always check params first
    body = template.html
  else
    subject = params[:email_broadcast_draft][:subject]
    body = params[:email_broadcast_draft][:body]
  end

  if uploaded_file.nil? || subject.blank? || body.blank?
    redirect_to new_email_broadcast_path, alert: "All fields are required (including subject)."
    return
  end

  should_return = upload_file_and_check_should_return(uploaded_file, subject, body)
  return if should_return

  redirect_to new_email_broadcast_path, notice: "Emails are being sent in the background."
end


  
  def upload_file_and_check_should_return(file, subject, body)
        return unless file.present?
        redirect_to new_email_broadcast_path, alert: t("please_select_a_file") if file.nil?
        return true if file.blank?

       # Upload file to S3 using S3FileUploader service
       environment = Rails.env.production? ? "prod" : "dev"
       begin
        puts "Uploading file to S3: #{file.tempfile.path}"
        @file_url = S3FileUploader.upload(file.tempfile.path, environment)
       rescue StandardError => e
          redirect_to new_email_broadcast_path, alert: t("upload_to_s3_error") + ": #{e.message}"
          return true
       end

      service = BroadcastExcelImportService.new(@file_url)
      emails = service.import
      email_setting_id = EmailSetting.find_by(added_by: current_user)&.id
      BroadcastEmailsJob.perform_later(emails, subject, body.to_s, email_setting_id)
      return false
  end
end
