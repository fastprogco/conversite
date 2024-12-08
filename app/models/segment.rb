class Segment < ApplicationRecord
    belongs_to :master_segment
    belongs_to :added_by, class_name: "User"
    belongs_to :edited_by, class_name: "User", optional: true
    belongs_to :deleted_by, class_name: "User", optional: true

    validates :mobile, presence: true
    validates :person_name, presence: true
    validates :person_email, presence: true
    validates :master_segment_id, presence: true
end
