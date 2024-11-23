require 'open-uri'
require 'tempfile'
  
class MasterExcelImportService
     BATCH_SIZE = 1000

    def initialize(file_url)
       @file_url = file_url
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
         sheet.each_row_streaming(offset: 1) do |row|
            mobile = row[3]&.cell_value&.gsub('-', '')
            secondary_mobile_number = row[23]&.gsub('-', '')
            date = row[1]&.cell_value ? Date.new(1899, 12, 30) + row[1]&.cell_value.to_i : nil
            passport_expiry_date = row[26]&.cell_value ?  Date.new(1899, 12, 30) + row[26]&.cell_value.to_i : nil
            birthdate =  row[27]&.cell_value ?  Date.new(1899, 12, 30) + row[27]&.cell_value.to_i : nil

           records << {
             file_name: row[0]&.cell_value || '',
             date: date || '',
             name: row[2]&.cell_value  || '',
             mobile: mobile || '',
             nationality: row[4]&.cell_value || '',
             procedure: row[5]&.cell_value || '',
             procedure_name: row[6]&.cell_value || '',
             amount: row[7]&.cell_value || '',
             area_name: row[8]&.cell_value || '',
             combine: row[9]&.cell_value || '',
             master_project: row[10]&.cell_value || '',
             project: row[11]&.cell_value || '',
             plot_pre_reg_num: row[12]&.cell_value || '',
             building_num: row[13]&.cell_value || '',
             building_name: row[14]&.cell_value || '',
             size: row[15]&.cell_value || '',
             unit_number: row[16]&.cell_value || '',
             dm_num: row[17]&.cell_value || '',
             dm_sub_num: row[18]&.cell_value || '',
             property_type: row[19]&.cell_value || '',
             land_number: row[20]&.cell_value || '',
             land_sub_num: row[21]&.cell_value || '',
             phone: row[22]&.cell_value || '',
             secondary_mobile_number: secondary_mobile_number || '',
             id_number: row[24]&.cell_value || '',
             uae_id: row[25]&.cell_value || '',
             passport_expiry_date: passport_expiry_date || '',
             birthdate: birthdate || '',
             unified_num: row[28]&.cell_value || '',
             email: row[29]&.cell_value || '',
             extra_info_1: row[30]&.cell_value || '',
             extra_info_2: row[31]&.cell_value || '',
             extra_info_3: row[32]&.cell_value || '',
           }

           if records.size >= BATCH_SIZE
             Master.insert_all(records)
             records.clear
           end
         end

         # Insert any remaining records
         Master.insert_all(records) unless records.empty?
       ensure
         temp_file.close
         temp_file.unlink
       end
    end
  end