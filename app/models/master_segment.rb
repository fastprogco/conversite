class MasterSegment < ApplicationRecord
    belongs_to :added_by, class_name: "User"
    has_many :segments
    has_and_belongs_to_many :chatbots

    validates :name, :description,presence: true
    validates :name, uniqueness: true

    enum table_type_id: { master: 1 }

end
