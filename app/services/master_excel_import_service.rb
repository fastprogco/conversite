require 'open-uri'
require 'tempfile'
  
class MasterExcelImportService
     BATCH_SIZE = 1000

    def initialize(file_url)
       @file_url = file_url
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

           mobile = row[3]&.to_s&.gsub('-', '')
           secondary_mobile_number = row[23]&.to_s&.gsub('-', '')
        
           date = safe_parse_date(row[1])
           passport_expiry_date = safe_parse_date(row[26])
           birthdate = safe_parse_date(row[27])

           records << {
             file_name: row[0]&.to_s || '',
             date: date || '',
             name: row[2]&.to_s || '',
             mobile: mobile || '',
             nationality: row[4]&.to_s || '',
             procedure: row[5]&.to_s || '',
             procedure_name: row[6]&.to_s || '',
             amount: row[7]&.to_s || '',
             area_name: row[8]&.to_s || '',
             combine: row[9]&.to_s || '',
             master_project: row[10]&.to_s || '',
             project: row[11]&.to_s || '',
             plot_pre_reg_num: row[12]&.to_s || '',
             building_num: row[13]&.to_s || '',
             building_name: row[14]&.to_s || '',
             size: row[15]&.to_s || '',
             unit_number: row[16]&.to_s || '',
             dm_num: row[17]&.to_s || '',
             dm_sub_num: row[18]&.to_s || '',
             property_type: row[19]&.to_s || '',
             land_number: row[20]&.to_s || '',
             land_sub_num: row[21]&.to_s || '',
             phone: row[22]&.to_s || '',
             secondary_mobile_number: secondary_mobile_number || '',
             id_number: row[24]&.to_s || '',
             uae_id: row[25]&.to_s || '',
             passport_expiry_date: passport_expiry_date || '',
             birthdate: birthdate || '',
             unified_num: row[28]&.to_s || '',
             email: row[29]&.to_s || '',
             extra_info_1: row[30]&.to_s || '',
             extra_info_2: row[31]&.to_s || '',
             extra_info_3: row[32]&.to_s || '',
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