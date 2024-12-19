require 'open-uri'
require 'tempfile'
require 'creek'

class MasterExcelImportService
  BATCH_SIZE = 1000

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
        mobile = normalized_row["D"]&.gsub('-', '')
        secondary_mobile_number = normalized_row["X"]&.gsub('-', '')

        date = safe_parse_date(normalized_row["B"])
        passport_expiry_date = safe_parse_date(normalized_row["AA"])
        birthdate = safe_parse_date(normalized_row["AB"])

        records << {
          file_name: normalized_row["A"] || '',
          date: date || '',
          name: normalized_row["C"] || '',
          mobile: mobile || '',
          nationality: normalized_row["E"] || '',
          procedure: normalized_row["F"] || '',
          procedure_name: normalized_row["G"] || '',
          amount: normalized_row["H"] || '',
          area_name: normalized_row["I"] || '',
          combine: normalized_row["J"] || '',
          master_project: normalized_row["K"] || '',
          project: normalized_row["L"] || '',
          plot_pre_reg_num: normalized_row["M"] || '',
          building_num: normalized_row["N"] || '',
          building_name: normalized_row["O"] || '',
          size: normalized_row["P"] || '',
          unit_number: normalized_row["Q"] || '',
          dm_num: normalized_row["R"] || '',
          dm_sub_num: normalized_row["S"] || '',
          property_type: normalized_row["T"] || '',
          land_number: normalized_row["U"] || '',
          land_sub_num: normalized_row["V"] || '',
          phone: normalized_row["W"] || '',
          secondary_mobile_number: secondary_mobile_number || '',
          id_number: normalized_row["Y"] || '',
          uae_id: normalized_row["Z"] || '',
          passport_expiry_date: passport_expiry_date || '',
          birthdate: birthdate || '',
          unified_num: normalized_row["AC"] || '',
          email: normalized_row["AD"] || '',
          extra_info_1: normalized_row["AE"] || '',
          extra_info_2: normalized_row["AF"] || '',
          extra_info_3: normalized_row["AG"] || '',
        }

        if records.size >= BATCH_SIZE
          Master.insert_all(records)
          puts "Inserted batch of #{records.size} records"
          records.clear
        end
      end


      # Insert any remaining records
      unless records.empty?
        Master.insert_all(records)
        puts "Inserted final batch of #{records.size} records"
      end
    ensure
      temp_file.close
      temp_file.unlink
    end
  end
end
