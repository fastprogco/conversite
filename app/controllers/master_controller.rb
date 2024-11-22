class MastersController < ApplicationController
     def import
       file_path = params[:file].path
       MasterExcelImportJob.perform_later(file_path)
       redirect_to masters_path, notice: 'Data import is in progress'
    end
end