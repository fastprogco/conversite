class WhatsappAccount < ApplicationRecord
    belongs_to :added_by, class_name: "User"
    belongs_to :edited_by, class_name: "User", optional: true
    belongs_to :deleted_by, class_name: "User", optional: true
    validates :whatsapp_mobile_number, 
            :app_id, 
            :phone_number_id, 
            :whatsapp_business_account_id, 
            :token, 
            uniqueness: true
    validates :name, :whatsapp_mobile_number, :app_id, :phone_number_id, :whatsapp_business_account_id, :token, :webhook_version, presence: true
    validates :added_by, 
          uniqueness: { conditions: -> { where(is_deleted: false) }, 
                        message: "already has a WhatsApp account" }
end