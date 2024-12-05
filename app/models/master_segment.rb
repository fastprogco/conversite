class MasterSegment < ApplicationRecord
    belongs_to :added_by, class_name: "User"
    has_many :chatbots
    has_many :segments

    validates :name, :description, :table_type_id, presence: true
    validates :name, uniqueness: true

    enum table_type_id: { master: 1 }

end
