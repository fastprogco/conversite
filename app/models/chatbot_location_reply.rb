class ChatbotLocationReply < ApplicationRecord
  belongs_to :chatbot_step
  belongs_to :chatbot

  belongs_to :added_by, class_name: "User", optional: true
  belongs_to :edited_by, class_name: "User", optional: true
  belongs_to :deleted_by, class_name: "User", optional: true

  validates :location_name, :location_address, :location_latitude, :location_longitude, presence: true
  validates :location_name, :location_address, length: { maximum: 255 }
  validates :location_latitude, :location_longitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }

end
