class WhatsappAccount < ApplicationRecord
    belongs_to :added_by, class_name: "User"
    belongs_to :edited_by, class_name: "User", optional: true
    belongs_to :deleted_by, class_name: "User", optional: true
    validates :whatsapp_mobile_number, 
                :app_id, 
                :phone_number_id, 
                :whatsapp_business_account_id, 
                :token, 
                uniqueness: { conditions: -> { where(is_deleted: false) } }
                        
    validates :name, :whatsapp_mobile_number, :app_id, :phone_number_id, :whatsapp_business_account_id, :token, :webhook_version, presence: true, unless: :being_soft_deleted?
    validates :added_by, 
          uniqueness: { conditions: -> { where(is_deleted: false) }, 
                        message: "already has a WhatsApp account" }

                        
  default_scope { where(is_deleted: false) }

   def soft_delete(user)
    update_columns(
      is_deleted: true,
      deleted_by_id: user.id,
    )
  end

  private

  def being_soft_deleted?
    is_deleted_changed? && is_deleted == true
  end

  def deleted_or_being_deleted?
    is_deleted || (is_deleted_changed? && is_deleted == true)
  end

end