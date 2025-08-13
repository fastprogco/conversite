require 'open-uri'
require 'tempfile'
require 'creek'
require 'securerandom'

class BroadcastExcelImportService
  def initialize(file_url)
    @file_url = file_url
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

  # This method downloads the Excel file, extracts all mobile numbers from column "D",
  # cleans them by removing dashes, and returns an array of unique mobile numbers.
  def import
    temp_file = Tempfile.new(["excel_import_#{Time.now.to_i}_#{SecureRandom.hex(8)}", '.xlsx'])
    items = []
    begin
      temp_file.binmode
      puts "Downloading file from URL: #{@file_url}"
      URI.open(@file_url) do |file|
        temp_file.write(file.read)
      end
      temp_file.rewind

      xlsx = Creek::Book.new(temp_file.path)
      sheet = xlsx.sheets[0]

      skip_header = true

      sheet.rows.each do |row|
        if skip_header
          skip_header = false
          next
        end

        normalized_row = row.transform_keys { |key| key.gsub(/\d+$/, '') }
        next if normalized_row.values.compact.empty?

        item = normalized_row["A"]
        puts "Extracted item: #{item}"
        items << item if item && !item.empty?
      end
    ensure
      temp_file.close
      temp_file.unlink
    end

    items.uniq

    puts "Extracted mobile numbers: #{items.inspect}"
    items
  end
end
