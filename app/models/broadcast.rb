class Broadcast < ApplicationRecord
    belongs_to :whatsapp_account
    belongs_to :template
    belongs_to :master_segment
    belongs_to :added_by, class_name: "User"
    belongs_to :edited_by, class_name: "User", optional: true
    belongs_to :deleted_by, class_name: "User", optional: true

    validates :name, presence: true
    validates :timing, presence: true
    validates :whatsapp_account, presence: true
    validates :template, presence: true
    validates :master_segment, presence: true
    validates :added_by, presence: true

    enum timing: {
        send_now: 1,
        schedule: 2
    }
end
