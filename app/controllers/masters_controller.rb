class MastersController < ApplicationController

     def excel_import_new
     end

     def import_excel
       uploaded_file = params[:file]
       return redirect_to excel_import_show_masters_path, alert: 'Please select a file' if uploaded_file.nil?

       file_path = Rails.root.join('public', 'uploads', uploaded_file.original_filename)
       File.open(file_path, 'wb') do |file|
         file.write(uploaded_file.read)
       end

       MasterExcelImportJob.perform_later(file_path.to_s)
       redirect_to masters_path, notice: 'File uploaded successfully and data import is in progress'
     rescue StandardError => e
       redirect_to excel_import_show_masters_path, alert: "Error: #{e.message}"
     end

     def index
       @masters = Master.all
     end

end