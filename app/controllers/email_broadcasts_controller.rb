class EmailBroadcastsController < ApplicationController
  before_action :authorize_super_admin, only: [:new, :create]

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

      subject = params[:subject].presence || template.title
      body    = template.html_file.attached? ? template.html_file.download : template.html
      body    = body.to_s
      attachment_files = [] # empty for template
    else
      @email_broadcast_draft = EmailBroadcastDraft.new(email_broadcast_draft_params)

      unless @email_broadcast_draft.save
        redirect_to new_email_broadcast_path, alert: "Could not save email draft."
        return
      end

      subject = @email_broadcast_draft.subject
      body    = @email_broadcast_draft.body.to_s

      # Upload ActionText attachments to S3 and keep original filenames
      environment = Rails.env.production? ? "prod" : "dev"
      attachment_files = @email_broadcast_draft.body.body.attachments.map do |att|

        puts "Processing attachment: #{att.filename}"
        blob = att.attachable.is_a?(ActiveStorage::Blob) ? att.attachable : nil
        next unless blob

        begin
          tempfile_path = ActiveStorage::Blob.service.send(:path_for, blob.key)
          s3_url = S3FileUploader.upload(tempfile_path, environment)
          { url: s3_url, filename: blob.filename.to_s }
        rescue => e
          Rails.logger.error "Attachment upload failed: #{e.message}"
          nil
        end
      end.compact
    end

    if uploaded_file.nil? || subject.blank? || body.blank?
      redirect_to new_email_broadcast_path, alert: "All fields are required (including subject)."
      return
    end

    should_return = upload_file_and_check_should_return(
      uploaded_file,
      subject,
      body,
      attachment_files, # pass array of hashes {url, filename}
      @email_broadcast_draft&.id
    )
    return if should_return

    redirect_to new_email_broadcast_path, notice: "Emails are being sent in the background."
  end

  def upload_file_and_check_should_return(file, subject, body, attachment_files, draft_id)
    return unless file.present?
    redirect_to new_email_broadcast_path, alert: t("please_select_a_file") if file.nil?
    return true if file.blank?

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

    puts "Attachment files: #{attachment_files.inspect}"
    BroadcastEmailsJob.perform_later(emails, subject, body.to_s, email_setting_id, attachment_files, draft_id)
    false
  end

  private

  def email_broadcast_draft_params
    params.require(:email_broadcast_draft).permit(:subject, :body)
  end
end
