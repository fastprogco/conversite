class Chatbot < ApplicationRecord
    has_many :chatbot_steps, dependent: :destroy
    has_many :chatbot_button_replies
    belongs_to :master_segment, optional: true

    validates :name, presence: true
    validates :description, presence: true

    belongs_to :created_by, class_name: 'User', optional: true
    belongs_to :edited_by, class_name: 'User', optional: true
    belongs_to :deleted_by, class_name: 'User', optional: true

    validate :only_one_default_chatbot

    private

    def only_one_default_chatbot
        if master_segment_id.nil? && Chatbot.where(master_segment_id: nil).where.not(id: id).exists?
            errors.add(:chatbot, "can only have one default chatbot without a segment")
        end
    end
end
