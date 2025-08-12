class S3FileUploader
  def self.upload(file_path, environment)
    puts "Starting upload to S3: #{file_path}"
    # Extract the file name from the file path
    file_name = File.basename(file_path)

    # Generate a unique object key
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    unique_id = SecureRandom.uuid
    object_key = "uploads/#{timestamp}_#{unique_id}_#{file_name}"

    # Retrieve the bucket name from credentials
    bucket = Rails.application.credentials.dig(:aws, environment.to_sym, :bucket)

    # Upload the file
    File.open(file_path, 'rb') do |file|
      S3_CLIENT.put_object(bucket: bucket, key: object_key, body: file)
    end
    
    # Return the S3 file path
    "https://#{bucket}.s3.amazonaws.com/#{object_key}"
  rescue Aws::S3::Errors::ServiceError => e
    puts "Upload Failed: #{e.message}"
    nil
  end
end