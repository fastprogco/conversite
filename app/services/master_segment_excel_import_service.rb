require 'open-uri'
require 'tempfile'
require 'creek'

class MasterSegmentExcelImportService
  BATCH_SIZE = 1000

  def initialize(file_url, master_segment_id, added_by_id)
    @file_url = file_url
    @master_segment_id = master_segment_id
    @added_by_id = added_by_id
  end

  def safe_parse_date(value)
    return nil if value.nil?

    begin
      date = Date.parse(value.to_s)
      return date if date.year.between?(1900, 9999) # Validate reasonable year range
      nil
    rescue
      nil
    end
  end

  def import
    # Download file from S3
    temp_file = Tempfile.new(["excel_import_#{Time.now.to_i}_#{SecureRandom.hex(8)}", '.xlsx'])
    begin
      temp_file.binmode
      URI.open(@file_url) do |file|
        temp_file.write(file.read)
      end
      temp_file.rewind

      # Process the downloaded file
      xlsx = Creek::Book.new(temp_file.path)
      sheet = xlsx.sheets[0]

      records = []
      skip_header = true # Flag to skip the header row

      sheet.rows.each do |row|
        # Skip the header row
        if skip_header
          skip_header = false
          next
        end

        # Normalize keys by removing the row number suffix
        normalized_row = row.transform_keys { |key| key.gsub(/\d+$/, '') }

        # Skip empty rows
        next if normalized_row.values.compact.empty?

        # Log the row being processed
        puts "Processing row: #{normalized_row.inspect}"

        # Access normalized keys (e.g., "A", "B", "C" instead of "A2", "B2", "C2")
        mobile = normalized_row["B"]&.gsub('-', '')

        records << {
          master_segment_id: @master_segment_id,
          person_name: normalized_row["A"] || '',
          mobile: mobile || '',
          nationality: normalized_row["C"] || '',
          person_email: normalized_row["D"] || '',
          added_by_id: @added_by_id,
          added_on: DateTime.now.utc,
        }

        if records.size >= BATCH_SIZE
          Segment.insert_all(records)
          puts "Inserted batch of #{records.size} records"
          records.clear
        end
      end

      # Insert any remaining records
      unless records.empty?
        Segment.insert_all(records)
        puts "Inserted final batch of #{records.size} records"
      end
    ensure
      temp_file.close
      temp_file.unlink
    end
  end
end
