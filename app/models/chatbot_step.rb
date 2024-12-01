class ChatbotStep < ApplicationRecord
    belongs_to :chatbot
    belongs_to :previous_chatbot_step, class_name: "ChatbotStep", optional: true
    belongs_to :created_by, class_name: "User"
    belongs_to :edited_by, class_name: "User", optional: true
    belongs_to :deleted_by, class_name: "User", optional: true

    validates :header, length: { maximum: 60 }
    validates :description, presence: true, length: { maximum: 1024 }
    validates :footer, length: { maximum: 60 }
    validates :list_button_caption, length: { maximum: 20 }

    validate :previous_chatbot_step_belongs_to_same_chatbot

    def previous_chatbot_step_belongs_to_same_chatbot
        if previous_chatbot_step && previous_chatbot_step.chatbot != chatbot
            errors.add(:previous_chatbot_step_id, "must belong to the same chatbot")
        end
    end
end
