class S3FileUploader
  require 'securerandom'
  require 'aws-sdk-s3'
  require 'cgi'

  # Upload from file path
  def self.upload(file_path, environment)
    file_name = File.basename(file_path)
    object_key = generate_object_key(file_name)
    bucket = Rails.application.credentials.dig(:aws, environment.to_sym, :bucket)

    File.open(file_path, 'rb') do |file|
      S3_CLIENT.put_object(bucket: bucket, key: object_key, body: file)
    end

    # Escape URL to handle spaces/special characters
    "https://#{bucket}.s3.amazonaws.com/#{CGI.escape(object_key)}"
  rescue Aws::S3::Errors::ServiceError => e
    puts "Upload Failed: #{e.message}"
    nil
  end

  # Upload from IO (StringIO, Tempfile, etc.)
  def self.upload_from_io(io, filename, environment)
    object_key = generate_object_key(filename)
    bucket = Rails.application.credentials.dig(:aws, environment.to_sym, :bucket)

    S3_CLIENT.put_object(bucket: bucket, key: object_key, body: io)

    # Escape URL
    "https://#{bucket}.s3.amazonaws.com/#{CGI.escape(object_key)}"
  rescue Aws::S3::Errors::ServiceError => e
    puts "Upload Failed: #{e.message}"
    nil
  end

  private

  def self.generate_object_key(filename)
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    unique_id = SecureRandom.uuid
    "uploads/#{timestamp}_#{unique_id}_#{filename}"
  end
end
