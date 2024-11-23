class MastersController < ApplicationController

     def excel_import_new
     end

     def import_excel
       uploaded_file = params[:file]
       return redirect_to excel_import_show_masters_path, alert: 'Please select a file' if uploaded_file.nil?

       # Upload file to S3 using S3FileUploader service
       begin
        @file_url = S3FileUploader.upload(uploaded_file.tempfile.path, "dev")
       rescue StandardError => e
         return redirect_to excel_import_show_masters_path, alert: "Upload To S3 Error: #{e.message}"
       end

       MasterExcelImportJob.perform_later(@file_url)
       redirect_to masters_path, notice: 'Data import is in progress'
     rescue StandardError => e
       redirect_to excel_import_show_masters_path, alert: "Error: #{e.message}"
     end

     def index
       @masters = Master.all
     end

end