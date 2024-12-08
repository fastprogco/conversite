class Chatbot < ApplicationRecord
    has_many :chatbot_steps
    has_many :chatbot_button_replies
    has_and_belongs_to_many :master_segments

    validates :name, presence: true
    validates :description, presence: true

    belongs_to :created_by, class_name: 'User', optional: true
    belongs_to :edited_by, class_name: 'User', optional: true
    belongs_to :deleted_by, class_name: 'User', optional: true

    validate :only_one_default_chatbot

    private

    def only_one_default_chatbot
        if master_segments.empty? && Chatbot.where(master_segments: []).exists?
            errors.add(:chatbot, "can only have one default chatbot without a segment")
        end
    end
end
