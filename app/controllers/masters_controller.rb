class MastersController < ApplicationController
     before_action :authorize_super_admin, only: [:excel_import_new, :import_excel, :index, :export, :create_segment]

     def excel_import_new
     end

     def import_excel
       uploaded_file = params[:file]
       return redirect_to excel_import_new_masters_path, alert: t("please_select_a_file") if uploaded_file.nil?

       # Upload file to S3 using S3FileUploader service
       begin
        @file_url = S3FileUploader.upload(uploaded_file.tempfile.path, "dev")
       rescue StandardError => e
         return redirect_to excel_import_new_masters_path, alert: t("upload_to_s3_error") + ": #{e.message}"
       end

       MasterExcelImportJob.perform_later(@file_url)
       redirect_to masters_path, notice: t("data_import_is_in_progress")
     rescue StandardError => e
       redirect_to excel_import_new_masters_path, alert: t("error") + ": #{e.message}"
     end

     def index
      @page = params[:page] || 1
      @count = Master.count
   
      get_masters
      @selected_masters_count = @masters.count
      @masters = @masters.page(@page).order(created_at: :desc).per(10)
     end

    def export
      get_masters
      @column_groups = [
        ['file_name', 'date', 'name', 'mobile', 'nationality', 'procedure', 'procedure_name', 'amount', 'area_name'],
        ['combine', 'master_project', 'project', 'plot_pre_reg_num', 'building_num', 'building_name', 'size', 'unit_number', 'dm_num'],
        ['dm_sub_num', 'property_type', 'land_number', 'land_sub_num', 'phone', 'secondary_mobile_number', 'id_number', 'uae_id', 'passport_expiry_date'],
        ['birthdate', 'unified_num', 'email', 'extra_info_1', 'extra_info_2', 'extra_info_3']
      ]
      @selected_columns = if params[:columns].present?
        @column_groups.flatten.select { |column| params[:columns][column] == '1' }
      else
        @column_groups.flatten
      end

      respond_to do |format|
        format.xlsx {
          response.headers['Content-Disposition'] = 'attachment; filename=masters.xlsx'
        }
      end
    end

    def create_segment
      get_masters
      name = params[:name]
      description = params[:description]
      split_entries = params[:split_entries].to_i
      
      master_ids = @masters.pluck(:id)
      entries_per_segment = (master_ids.size.to_f / split_entries).ceil
      
      # Check if any of the segment names already exist
      exists = false
      split_entries.times do |i|
        segment_name = "#{name.strip.downcase} part_#{i + 1}"
        if MasterSegment.exists?(name: segment_name)
          exists = true
          return redirect_to masters_path, alert: "Segment name '#{segment_name}' already exists"
        end
        break if exists
      end

      split_entries.times do |i|
        segment_name = "#{name.strip.downcase} part_#{i + 1}"
        segment_description = "#{description}"
        
        start_idx = i * entries_per_segment
        end_idx = [start_idx + entries_per_segment, master_ids.size].min
        segment_master_ids = master_ids[start_idx...end_idx]
        
        puts "segment_master_ids: #{segment_master_ids}"

        master_segment = MasterSegment.new(
          name: segment_name,
          description: segment_description,
          table_type_id: :master,
          added_by_id: current_user.id,
          added_on: DateTime.now.utc
        )
        
        if master_segment.save
          MasterSegmentCreationJob.perform_later(
            master_segment.id,
            segment_master_ids,
            current_user.id
          )
        else
          return redirect_to masters_path, alert: master_segment.errors.full_messages.join(", ")
        end
      end
      
      redirect_to masters_path, notice: t("segment_creation_in_progress")
    end

    private 
    def get_masters
      search_column = params[:search_column]
      search_term = params[:search_term]
      exclude_term = params[:exclude_term]
      exclude_empty = params[:exclude_empty]

      @masters = Master.all
      if search_column.present? && search_term.present?
        search_column.each_with_index do |column, index|
          next if column.blank? 

          if search_column.present? && search_term[index].present?
            @masters = @masters.where("#{column} ILIKE ?", "%#{search_term[index]}%")
          end
          
          if exclude_term.present? && exclude_term[index].present?
            @masters = @masters.where.not("#{column} ILIKE ?", "%#{exclude_term[index]}%")
          end

          if exclude_empty.present? && exclude_empty[index].present?
            @masters = @masters.where.not("#{column}": "")
          end
        end
        @masters = @masters.order(created_at: :desc)
      end
    end
end