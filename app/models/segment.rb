class Segment < ApplicationRecord
    belongs_to :added_by, class_name: "User"
    belongs_to :edited_by, class_name: "User", optional: true
    belongs_to :deleted_by, class_name: "User", optional: true

    validates :name, :description, :table_type_id, :table_id, presence: true
    enum table_type_id: { master: 1 }
end
