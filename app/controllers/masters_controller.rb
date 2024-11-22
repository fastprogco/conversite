class MastersController < ApplicationController

     def excel_import_new
     end

     def import_excel
       uploaded_file = params[:file]
       return redirect_to excel_import_show_masters_path, alert: 'Please select a file' if uploaded_file.nil?
       
       temp_file_path = Rails.root.join('tmp', uploaded_file.original_filename)
       File.binwrite(temp_file_path, uploaded_file.read)
       
       MasterExcelImportJob.perform_later(temp_file_path.to_s)
       redirect_to masters_path, notice: 'Data import is in progress'
     rescue StandardError => e
       redirect_to excel_import_show_masters_path, alert: "Error: #{e.message}"
     end

end