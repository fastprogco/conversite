class MasterSegment < ApplicationRecord
    belongs_to :added_by, class_name: "User"
    has_many :segments
    has_and_belongs_to_many :chatbots

    validates :name, presence: true
    validates :name, uniqueness: true

    before_validation :strip_name

    enum table_type_id: { master: 1 }

    private

    def strip_name
        self.name = name.strip if name.present?
    end

end
