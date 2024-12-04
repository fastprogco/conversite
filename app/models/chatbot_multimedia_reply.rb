class ChatbotMultimediaReply < ApplicationRecord
  belongs_to :chatbot
  belongs_to :chatbot_step

  belongs_to :added_by, class_name: "User", optional: true
  belongs_to :edited_by, class_name: "User", optional: true
  belongs_to :deleted_by, class_name: "User", optional: true
    
  validates :media_type_id, presence: true
  validates :text_body, presence: true, if: -> { media_type_id == 1 }
  validates :file_caption, presence: true, if: -> { media_type_id == 2 || media_type_id == 3 || media_type_id == 4 || media_type_id == 5  }
  validates :order, presence: true
  enum media_type_id: {
    text: 1,
    image: 2,
    audio: 3,
    document: 4,
    video: 5,
    location: 6
  }



end
