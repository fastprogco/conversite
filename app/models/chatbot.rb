class Chatbot < ApplicationRecord
    has_many :chatbot_steps, dependent: :destroy
    has_many :chatbot_button_replies

    validates :name, presence: true
    validates :description, presence: true

    belongs_to :created_by, class_name: 'User', optional: true
    belongs_to :edited_by, class_name: 'User', optional: true
    belongs_to :deleted_by, class_name: 'User', optional: true
end
