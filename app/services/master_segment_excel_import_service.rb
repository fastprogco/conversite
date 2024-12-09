require 'open-uri'
require 'tempfile'

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
      date = Date.new(1899, 12, 30) + value.to_i
      return date if date.year.between?(1900, 9999) # Validate year range
      nil
    rescue
      nil
    end
  end

  def import
    # Download file from S3
    temp_file = Tempfile.new(["excel_import_#{Time.now.to_i}_#{SecureRandom.hex(8)}", '.xlsx'])

    puts "Downloading file from S3: #{@file_url}"
    begin
      temp_file.binmode
      URI.open(@file_url) do |file|
        temp_file.write(file.read)
      end
      temp_file.rewind

      # Process the downloaded file
      xlsx = Roo::Spreadsheet.open(temp_file.path)
      sheet = xlsx.sheet(0)

      records = []
      # Skip header row and only process rows with actual data
      ((sheet.first_row + 1)..sheet.last_row).each do |row_num|
        row = sheet.row(row_num)
        # Skip empty rows
        next if row.compact.empty?

        # Log the row being processed
        puts "Processing row #{row_num}: #{row.inspect}"

        #mobile = row[3]&.to_s&.gsub('-', '')
        
        records << {
          master_segment_id: @master_segment_id,
          person_name: row[0]&.to_s || '',
          mobile: row[1]&.to_s || '',
          nationality: row[2]&.to_s || '',
          person_email: row[3]&.to_s || '',
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
