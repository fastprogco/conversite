class MastersController < ApplicationController

     def excel_import_new
     end

     def import_excel
       uploaded_file = params[:file]
       return redirect_to excel_import_new_masters_path, alert: 'Please select a file' if uploaded_file.nil?

       # Upload file to S3 using S3FileUploader service
       begin
        @file_url = S3FileUploader.upload(uploaded_file.tempfile.path, "dev")
       rescue StandardError => e
         return redirect_to excel_import_new_masters_path, alert: "Upload To S3 Error: #{e.message}"
       end

       MasterExcelImportJob.perform_later(@file_url)
       redirect_to masters_path, notice: 'Data import is in progress'
     rescue StandardError => e
       redirect_to excel_import_new_masters_path, alert: "Error: #{e.message}"
     end

     def index
      @page = params[:page] || 1
      @count = Master.count
      search_column = params[:search_column]
      search_term = params[:search_term]
      
      @masters = Master.all
      if search_column.present? && search_term.present?
        @masters = @masters.where("#{search_column} ILIKE ?", "%#{search_term}%")
      end
      
      @masters = @masters.limit(100).page(@page).per(10)
     end

end