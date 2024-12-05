class Segment < ApplicationRecord
    belongs_to :added_by, class_name: "User"
    belongs_to :edited_by, class_name: "User", optional: true
    belongs_to :deleted_by, class_name: "User", optional: true
    validates :table_id, :master_segment_id, presence: true
end
