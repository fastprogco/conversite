class ChatbotButtonReply < ApplicationRecord
    belongs_to :chatbot
    belongs_to :chatbot_step

    belongs_to :added_by, class_name: "User", optional: true
    belongs_to :edited_by, class_name: "User", optional: true
    belongs_to :deleted_by, class_name: "User", optional: true


    validates :title, presence: true, length: { maximum: 24 }
    validates :order, presence: true, numericality: { greater_than: 0 }
    validates :action_type_id, presence: true

    before_save :downcase_trigger_keyword

    def downcase_trigger_keyword
        self.trigger_keyword = self.trigger_keyword.strip.downcase if self.trigger_keyword.present?
    end

    enum action_type_id: {
        forward: 1,
        go_back_to_main: 2
    }
end

