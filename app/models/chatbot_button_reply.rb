class ChatbotButtonReply < ApplicationRecord
    belongs_to :chatbot
    belongs_to :chatbot_step

    belongs_to :added_by, class_name: "User"
    belongs_to :edited_by, class_name: "User"
    belongs_to :deleted_by, class_name: "User"

    validates :title, presence: true, length: { maximum: 24 }
    validates :order, presence: true, numericality: { greater_than: 0 }
    validates :action_type_id, presence: true

    enum action_type_id: {
        forward: 1,
        go_back_to_main: 2
    }
end

