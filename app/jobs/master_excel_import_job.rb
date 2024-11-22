   class MasterExcelImportJob < ApplicationJob
     queue_as :default

     def perform(file_path)
       MasterExcelImportService.new(file_path).import
     end
   end