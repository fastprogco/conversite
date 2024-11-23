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
           records << {
             file_name: row[0]&.cell_value || '',
             date: row[1]&.cell_value || '',
             mobile: row[2]&.cell_value || '',
             nationality: row[3]&.cell_value || '',
             procedure: row[4]&.cell_value || '',
             procedure_name: row[5]&.cell_value || '',
             amount: row[6]&.cell_value || '',
             area_name: row[7]&.cell_value || '',
             combine: row[8]&.cell_value || '',
             master_project: row[9]&.cell_value || '',
             project: row[10]&.cell_value || '',
             plot_pre_reg_num: row[11]&.cell_value || '',
             building_num: row[12]&.cell_value || '',
             building_name: row[13]&.cell_value || '',
             size: row[14]&.cell_value || '',
             unit_number: row[15]&.cell_value || '',
             dm_num: row[16]&.cell_value || '',
             dm_sub_num: row[17]&.cell_value || '',
             property_type: row[18]&.cell_value || '',
             land_number: row[19]&.cell_value || '',
             phone: row[20]&.cell_value || '',
             secondary_mobile_number: row[21]&.cell_value || '',
             id_number: row[22]&.cell_value || '',
             uae_id: row[23]&.cell_value || '',
             passport_expiry_date: row[24]&.cell_value || '',
             birthdate: row[25]&.cell_value || '',
             unified_num: row[26]&.cell_value || '',
             email: row[27]&.cell_value || '',
             extra_info_1: row[28]&.cell_value || '',
             extra_info_2: row[29]&.cell_value || '',
             extra_info_3: row[30]&.cell_value || '',
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