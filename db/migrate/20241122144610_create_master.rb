class CreateMaster < ActiveRecord::Migration[7.1]
 def change
    create_table :master do |t|
      t.string :file_name
      t.date :date
      t.string :mobile
      t.string :nationality
      t.string :procedure
      t.string :procedure_name
      t.decimal :amount, precision: 15, scale: 2
      t.string :area_name
      t.string :combine
      t.string :master_project
      t.string :project
      t.string :plot_pre_reg_num
      t.string :building_num
      t.string :building_name
      t.string :size
      t.string :unit_number
      t.string :dm_num
      t.string :dm_sub_num
      t.string :property_type
      t.string :land_number
      t.string :phone
      t.string :secondary_mobile_number
      t.string :id_number
      t.string :uae_id
      t.date :passport_expiry_date
      t.date :birthdate
      t.string :unified_num
      t.string :email
      t.text :extra_info_1
      t.text :extra_info_2
      t.text :extra_info_3
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
